// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./SimpleCommit.sol";

contract MontyHall {
    enum MontyHallStep {
        Bet,
        Reveal,
        Change,
        FinalReveal,
        Done
    }

    MontyHallStep public currentStep;
    SimpleCommit.CommitType[] doors;

    address payable interviewer;
    address payable player;

    uint8 playerSelectedDoor = 0;
    uint8 openDoor;
    uint public prize;
    uint public collateral;
    uint public startingStepTimeStamp;
    uint immutable timeLimit;

    event EverythingRevelead();
    event PlayerWon();
    event InterviewWon();

    constructor(
        bytes32 door0,
        bytes32 door1,
        bytes32 door2,
        uint _collateral,
        uint _timeLimit
    ) payable {
        doors.push(
            SimpleCommit.CommitType(
                door0,
                0,
                false,
                SimpleCommit.CommitStatesType.Waiting
            )
        );
        doors.push(
            SimpleCommit.CommitType(
                door1,
                0,
                false,
                SimpleCommit.CommitStatesType.Waiting
            )
        );
        doors.push(
            SimpleCommit.CommitType(
                door2,
                0,
                false,
                SimpleCommit.CommitStatesType.Waiting
            )
        );
        SimpleCommit.commit(doors[0], door0);
        SimpleCommit.commit(doors[1], door1);
        SimpleCommit.commit(doors[2], door2);

        interviewer = payable(msg.sender);
        currentStep = MontyHallStep.Bet;

        prize = msg.value;
        collateral = _collateral;

        startingStepTimeStamp = block.timestamp;
        timeLimit = _timeLimit;
    }

    modifier onlyInterviewer() {
        require(msg.sender == interviewer, "Only the interviewer can do this!");
        _;
    }

    modifier onlyPlayer() {
        require(msg.sender == player, "Only the player can do this!");
        _;
    }

    function bet(uint8 door) public payable {
        require(door >= 0 && door <= 2, "Door Range 0, 1 and 2");
        require(
            currentStep == MontyHallStep.Bet,
            "Should be in betting state!"
        );
        require(
            player == address(0x0) || player == msg.sender,
            "Already have a player!"
        );
        require(msg.value >= collateral, "Should transfer collateral");

        player = payable(msg.sender);
        playerSelectedDoor = door;

        currentStep = MontyHallStep.Reveal;
        startingStepTimeStamp = block.timestamp;
    }

    function getValue(uint door) public view returns (uint8) {
        return SimpleCommit.getValue(doors[door]);
    }

    function isDoorPrizeable(uint door) public view returns (bool) {
        return getValue(door) == 1;
    }

    function reveal(
        uint8 door,
        bytes32 nonce,
        uint8 v
    ) public onlyInterviewer returns (bool) {
        require(
            currentStep == MontyHallStep.Reveal,
            "Should be in the first reveal state"
        );
        require(door >= 0 && door <= 2, "Door Range 0, 1 and 2");
        require(door != playerSelectedDoor, "Player selected this door");
        SimpleCommit.reveal(doors[door], nonce, v);
        if (!SimpleCommit.isCorrect(doors[door]) || isDoorPrizeable(door)) {
            (bool sent,) = player.call{value: prize}("");
            require(sent, "Failed to transfer to Player");
            currentStep = MontyHallStep.Done;
            return false;
        }
        currentStep = MontyHallStep.Change;
        openDoor = door;
        startingStepTimeStamp = block.timestamp;
        return true;
    }

    function change(uint8 door) public onlyPlayer {
        require(currentStep == MontyHallStep.Change, "Must be in change step");
        require(door >= 0 && door <= 2, "Door Range 0, 1 and 2");
        require(door != openDoor, "This is the Open Door");
        playerSelectedDoor = door;
        currentStep = MontyHallStep.FinalReveal;
        startingStepTimeStamp = block.timestamp;
    }

    function isEverythingRevelead() public view returns (bool) {
        bool everythingRevelead = true;
        for (uint8 i = 0; i < 3; i++) {
            everythingRevelead =
                everythingRevelead &&
                SimpleCommit.isRevealed(doors[i]);
        }
        return everythingRevelead;
    }

    function finalReveal(
        uint door,
        bytes32 nonce,
        uint8 v
    ) public onlyInterviewer {
        require(
            currentStep == MontyHallStep.FinalReveal,
            "Should be in final reveal step"
        );
        SimpleCommit.reveal(doors[door], nonce, v);
        if (!SimpleCommit.isCorrect(doors[door])) {
            (bool sent,) = player.call{value: prize + collateral}("");
            require(sent, "Failed to transfer to Player");
            currentStep = MontyHallStep.Done;
            return;
        }

        if (isEverythingRevelead()) {
            emit EverythingRevelead();
            bool atLeastOneIsPrizeable = false;
            for (uint8 i = 0; i < 3; i++) {
                atLeastOneIsPrizeable =
                    atLeastOneIsPrizeable ||
                    isDoorPrizeable(i);
            }
            if (atLeastOneIsPrizeable && !isDoorPrizeable(playerSelectedDoor)) {
                currentStep = MontyHallStep.Done;
                (bool sentToPlayer,) = player.call{value: collateral}("");
                require(sentToPlayer, "Failed to transfer to Player");
                (bool sentToInterviewer,) = interviewer.call{value: prize}("");
                require(sentToInterviewer, "Failed to transfer to Interviewer");
                emit InterviewWon();
                return;
            }
            currentStep = MontyHallStep.Done;
            (bool sent,) = player.call{value: prize + collateral}("");
            require(sent, "Failed to transfer to Player");
            emit PlayerWon();
        }
    }

    function reclaimTimeLimit() public {
        require(msg.sender == interviewer || msg.sender == player);
        require(
            block.timestamp - startingStepTimeStamp > timeLimit,
            "Wait until time Limit is reached"
        );
        require(MontyHallStep.Done != currentStep, "Already ended");
        if (currentStep == MontyHallStep.Bet) {
            (bool sent,) = interviewer.call{value: prize}("");
            require(sent, "Failed to transfer to Interviewer");
            return;
        }
        if (currentStep == MontyHallStep.Reveal) {
            (bool sent,) = player.call{value: collateral + prize}("");
            require(sent, "Failed to transfer to Player");
            return;
        }
        if (currentStep == MontyHallStep.Change) {
            (bool sent,) = interviewer.call{value: collateral + prize}("");
            require(sent, "Failed to transfer to Interviewer");
            return;
        }
        if (currentStep == MontyHallStep.FinalReveal) {
            (bool sent,) = player.call{value: collateral + prize}("");
            require(sent, "Failed to transfer to Player");
            return;
        }
    }
}
