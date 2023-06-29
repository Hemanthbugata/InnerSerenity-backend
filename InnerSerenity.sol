// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract InnerSerenity {
    struct User {
        string name;
        uint age;
        string gender;
    }

    struct Professional {
        string name;
        string specialization;
        bool available;
        uint totalRatings;
        uint totalScore;
    }

    struct Conversation {
        address userAddress;
        address professionalAddress;
        string[] messages;
    }

    mapping(address => User) public users;
    mapping(address => Professional) public professionals;
    mapping(bytes32 => Conversation) public conversations;
    address[] public professionalAddresses;

    event AppointmentRequested(address indexed user, address indexed professional, bytes32 conversationId);

    function createUser(string memory _name, uint _age, string memory _gender) public {
        User storage newUser = users[msg.sender];
        newUser.name = _name;
        newUser.age = _age;
        newUser.gender = _gender;
    }

    function createProfessional(string memory _name, string memory _specialization) public {
        Professional storage newProfessional = professionals[msg.sender];
        newProfessional.name = _name;
        newProfessional.specialization = _specialization;
        newProfessional.available = true;
        professionalAddresses.push(msg.sender);
    }

    function searchProfessionals(string memory _specialization) public view returns (address[] memory) {
        uint count = 0;
        for (uint i = 0; i < professionalAddresses.length; i++) {
            address professionalAddress = professionalAddresses[i];
            Professional storage professional = professionals[professionalAddress];
            if (keccak256(bytes(professional.specialization)) == keccak256(bytes(_specialization)) && professional.available) {
                count++;
            }
        }

        address[] memory result = new address[](count);
        count = 0;
        for (uint i = 0; i < professionalAddresses.length; i++) {
            address professionalAddress = professionalAddresses[i];
            Professional storage professional = professionals[professionalAddress];
            if (keccak256(bytes(professional.specialization)) == keccak256(bytes(_specialization)) && professional.available) {
                result[count] = professionalAddress;
                count++;
            }
        }

        return result;
    }

    function requestAppointment(address _professionalAddress) public {
        Professional storage professional = professionals[_professionalAddress];
        require(professional.available, "Professional is not available");

        bytes32 conversationId = keccak256(abi.encodePacked(msg.sender, _professionalAddress));
        Conversation storage conversation = conversations[conversationId];
        conversation.userAddress = msg.sender;
        conversation.professionalAddress = _professionalAddress;

        emit AppointmentRequested(msg.sender, _professionalAddress, conversationId);
    }

    function sendMessage(bytes32 _conversationId, string memory _message) public {
        Conversation storage conversation = conversations[_conversationId];
        require(msg.sender == conversation.userAddress || msg.sender == conversation.professionalAddress, "Unauthorized access");

        conversation.messages.push(_message);
    }

    function rateProfessional(address _professionalAddress, uint _score) public {
        require(_score >= 1 && _score <= 5, "Invalid rating score");

        Professional storage professional = professionals[_professionalAddress];
        require(professional.totalRatings > 0, "Professional has not been rated yet");

        professional.totalRatings++;
        professional.totalScore += _score;
    }
}
