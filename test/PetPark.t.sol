// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/PetPark.sol";

contract PetParkTest is Test, PetPark {
    PetPark petPark;

    address testOwnerAccount;

    address testPrimaryAccount;
    address testSecondaryAccount;

    enum AnimalType {
        None,
        Fish,
        Cat,
        Dog,
        Rabbit,
        Parrot
    }

    enum Gender {
        Male,
        Female
    }

    function setUp() public {
        petPark = new PetPark();

        testOwnerAccount = msg.sender;
        testPrimaryAccount = address(0xABCD);
        testSecondaryAccount = address(0xABDC);
    }

    // I added uint8 while using enum because - enum value type should be uint8 but...
    // while calling I was getting the type error so I could not found better solution then this.
    // Please let me know if anyone knows the right solution for this. Thank you :)
    function testOwnerCanAddAnimal() public {
        petPark.add(uint8(AnimalType.Fish), 5);
    }

    function testCannotAddAnimalWhenNonOwner() public {
        // 1. Complete this test and remove the assert line below
        vm.prank(testPrimaryAccount);
        vm.expectRevert("Only owner can call this function!");
        petPark.add(uint8(AnimalType.Cat), 5);
    }

    function testCannotAddInvalidAnimal() public {
        vm.expectRevert("Invalid animal");
        petPark.add(uint8(AnimalType.None), 5);
    }

    function testExpectEmitAddEvent() public {
        vm.expectEmit(false, false, false, true);

        emit Added(uint8(AnimalType.Fish), 5);
        petPark.add(uint8(AnimalType.Fish), 5);
    }

    function testCannotBorrowWhenAgeZero() public {
        // 2. Complete this test and remove the assert line below
        vm.expectRevert("Age can not be zero");

        petPark.borrow(0, uint8(Gender.Male), uint8(AnimalType.Fish));
    }

    function testCannotBorrowUnavailableAnimal() public {
        petPark.add(uint8(AnimalType.Dog), 1);
        vm.prank(testPrimaryAccount);
        petPark.borrow(24, uint8(Gender.Male), uint8(AnimalType.Dog));

        vm.expectRevert("Selected animal not available");
        vm.prank(testSecondaryAccount);
        petPark.borrow(40, uint8(Gender.Male), uint8(AnimalType.Dog));
    }

    function testCannotBorrowInvalidAnimal() public {
        vm.expectRevert("Invalid animal type");

        petPark.borrow(24, uint8(Gender.Male), uint8(AnimalType.None));
    }

    function testCannotBorrowCatForMen() public {
        petPark.add(uint8(AnimalType.Cat), 5);

        vm.expectRevert("Invalid animal for men");
        petPark.borrow(24, uint8(Gender.Male), uint8(AnimalType.Cat));
    }

    function testCannotBorrowRabbitForMen() public {
        petPark.add(uint8(AnimalType.Rabbit), 5);

        vm.expectRevert("Invalid animal for men");
        petPark.borrow(24, uint8(Gender.Male), uint8(AnimalType.Rabbit));
    }

    function testCannotBorrowParrotForMen() public {
        petPark.add(uint8(AnimalType.Parrot), 5);

        vm.expectRevert("Invalid animal for men");
        petPark.borrow(24, uint8(Gender.Male), uint8(AnimalType.Parrot));
    }

    function testCannotBorrowForWomenUnder40() public {
        petPark.add(uint8(AnimalType.Cat), 5);

        vm.expectRevert("Invalid animal for women under 40");
        petPark.borrow(24, uint8(Gender.Female), uint8(AnimalType.Cat));
    }

    function testCannotBorrowTwiceAtSameTime() public {
        petPark.add(uint8(AnimalType.Fish), 5);
        petPark.add(uint8(AnimalType.Cat), 5);

        vm.prank(testPrimaryAccount);
        petPark.borrow(24, uint8(Gender.Male), uint8(AnimalType.Fish));

        vm.expectRevert("Already adopted a pet");
        vm.prank(testPrimaryAccount);
        petPark.borrow(24, uint8(Gender.Male), uint8(AnimalType.Fish));

        vm.expectRevert("Already adopted a pet");
        vm.prank(testPrimaryAccount);
        petPark.borrow(24, uint8(Gender.Male), uint8(AnimalType.Cat));
    }

    function testCannotBorrowWhenAddressDetailsAreDifferent() public {
        petPark.add(uint8(AnimalType.Fish), 5);

        vm.prank(testPrimaryAccount);
        petPark.borrow(24, uint8(Gender.Male), uint8(AnimalType.Fish));

        vm.expectRevert("Invalid Age or Gender!");
        vm.prank(testPrimaryAccount);
        petPark.borrow(23, uint8(Gender.Male), uint8(AnimalType.Fish));
    }

    function testExpectEmitOnBorrow() public {
        petPark.add(uint8(AnimalType.Fish), 5);
        vm.expectEmit(false, false, false, true);

        emit Borrowed(uint8(AnimalType.Fish));
        petPark.borrow(24, uint8(Gender.Male), uint8(AnimalType.Fish));
    }

    function testBorrowCountDecrement() public {
        petPark.add(uint8(AnimalType.Dog), 10);
        emit Borrowed(uint8(AnimalType.Dog));
        petPark.borrow(30, uint8(Gender.Female), uint8(AnimalType.Dog));
    }

    function testCannotGiveBack() public {
        vm.expectRevert("No borrowed pets");
        petPark.giveBackAnimal(uint8(AnimalType.Fish));
    }

    function testPetCountIncrement() public {
        petPark.add(uint8(AnimalType.Fish), 5);

        petPark.borrow(24, uint8(Gender.Male), uint8(AnimalType.Fish));
        uint reducedPetCount = petPark.animalCounts(uint8(AnimalType.Fish));

        petPark.giveBackAnimal(uint8(AnimalType.Fish));
        uint currentPetCount = petPark.animalCounts(uint8(AnimalType.Fish));

        assertEq(reducedPetCount, currentPetCount - 1);
    }
}
