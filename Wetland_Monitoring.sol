pragma solidity ^0.8.0;

contract wetland_monitoring
{
    struct monitoringparameters
    {
        uint256 pH;
        uint256 DO;
        uint256 temp;
        uint256 humidity;
        uint256 SM;
        uint256 tds;
        uint256 turb;
    }
    struct thresholds
    {
        uint256 pHthreshold;
         uint256 DOthreshold;
          uint256 tempthreshold;
           uint256 humiditythreshold;
            uint256 SMthreshold;
             uint256 tdsthreshold;
              uint256 turbthreshold;
    }
    thresholds public Threshold;
    mapping(address => bool) public eligibleForRewards;//Indicates whether the address is eligible for reward or not
    address public ethers;
    uint256 public reward;
    event ObservationRewarded(address indexed user, uint256 reward);
    constructor(uint256 _RewardInEther) 
    {
        reward = _RewardInEther * 1 ether; // Convert to wei
    }
      struct userobservation
      {
        string userobs;
        bool isvalid;
      }
      userobservation public uob;
      mapping(address => userobservation) public userobs;
    function submitObservation(string memory observation) public
    {
        uob.userobs= _observation;
        address owner;
        owner = msg.sender;
        require(msg.sender != owner, "Owner cannot submit observations.");//Indicates that the owner cannot submit the observations
    }
    function validateobservation(bool isaccurate) public 
    {
        uint256 pH;
        uint256 DO;
        uint256 SM;
        uint256 tds;
        uint256 turb;
        if (
            pH <= Threshold.pHthreshold ||
            turb <= Threshold.turbthreshold ||
            tds <= Threshold.tdsthreshold || 
            DO<= Threshold.DOthreshold ||
            SM<= Threshold.SMthreshold
        ) //Condition to check whether the observation provided by the user is accurate or not
{
            eligibleForRewards[msg.sender] = true;
            emit ObservationRewarded(msg.sender, reward);
        }
    }
    function claimReward() external 
    {
        require(eligibleForRewards[msg.sender], "User is not eligible for rewards");
        // Transfer rewards to the user
     payable(msg.sender).transfer(reward);

        eligibleForRewards[msg.sender] = false; // Mark the user as claimed
    }
    }

