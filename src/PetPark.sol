//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract PetPark {
    address public owner;

    struct borrower {
        address borrower;
        uint8 age;
        uint8 gender;
        bool borrowed;
    }

    uint8[] public animalTypes;
    mapping(uint8 => uint16) public animalCounts;
    mapping(address => borrower) public borrowers;

    event Added(uint8 animalType, uint16 animalCounts);
    event Borrowed(uint8 animalType);
    event Returned(uint8 animalType);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function!");
        _;
    }

    function isAnimalTypeExists(uint8 animalType) internal view returns (bool) {
        for (uint8 i = 0; i < animalTypes.length; i++) {
            if (animalTypes[i] == animalType) {
                return true;
            }
        }
        return false;
    }

    function add(uint8 animalType, uint16 counts) public onlyOwner {
        require(animalType >= 1 && animalType <= 5, "Invalid animal");
        uint16 oldCounts = animalCounts[animalType];
        animalCounts[animalType] = oldCounts + counts;
        if (!isAnimalTypeExists(animalType)) {
            animalTypes.push(animalType);
        }
        emit Added(animalType, counts);
    }

    function borrow(uint8 age, uint8 gender, uint8 animalType) public {
        uint16 oldCounts = animalCounts[animalType];
        if (borrowers[msg.sender].borrower == msg.sender) {
            require(
                borrowers[msg.sender].age == age &&
                    borrowers[msg.sender].gender == gender,
                "Invalid Age or Gender!"
            );
        }
        require(
            borrowers[msg.sender].borrowed == false,
            "Already adopted a pet"
        );
        require(age > 0, "Age can not be zero");
        require(isAnimalTypeExists(animalType), "Invalid animal type");
        require(oldCounts > 0, "Selected animal not available");
        if (gender == 0) {
            maleAsBorrower(animalType);
        } else {
            femaleAsBorrower(age, animalType);
        }
        borrower storage newBorrower = borrowers[msg.sender];
        newBorrower.borrower = msg.sender;
        newBorrower.age = age;
        newBorrower.gender = gender;
        newBorrower.borrowed = true;
        animalCounts[animalType] = oldCounts - 1;
        emit Borrowed(animalType);
    }

    function maleAsBorrower(uint8 animalType) internal pure {
        require(animalType == 1 || animalType == 3, "Invalid animal for men");
    }

    function femaleAsBorrower(uint8 age, uint8 animalType) internal pure {
        uint8 catValue = 2;
        if (age < 40)
            require(
                animalType != catValue,
                "Invalid animal for women under 40"
            );
    }

    function giveBackAnimal(uint8 animalType) public {
        require(borrowers[msg.sender].borrowed, "No borrowed pets");
        borrower storage newBorrower = borrowers[msg.sender];
        newBorrower.borrowed = false;
        uint16 oldCounts = animalCounts[animalType];
        animalCounts[animalType] = oldCounts + 1;
        emit Returned(animalType);
    }
}
