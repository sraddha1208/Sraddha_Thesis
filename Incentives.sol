// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract wetland_monitoring
{
    address public owner;//Declares a state variable used to store the ethereum address of the contract deployer
    mapping(address => uint256) public userObservationCount;
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
    monitoringparameters public MP;
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
    modifier onlyOwner() {
    require(msg.sender == owner, "Only contract owner can call this function");//
    _;
}//Used to restrict access to sethresholds function to only the owner of the contract 

    function sethresholds(uint256 _pHThreshold,
        uint256 _turbidityThreshold,
        uint256 _dissolvedOxygenThreshold,
        uint256 _SMThreshold,
        uint256 _tdsThreshold
    ) external onlyOwner {
        Threshold.pHthreshold = _pHThreshold;
        Threshold.turbthreshold = _turbidityThreshold;
        Threshold.DOthreshold = _dissolvedOxygenThreshold;
        Threshold.SMthreshold=_SMThreshold;
        Threshold.tdsthreshold=_tdsThreshold;
    }
    struct incentivemultiply
    {
        uint256 baseincentive;
        uint256 incen_mult;
    }
    incentivemultiply public IM;

    function incentivemultiplier(uint256 _baseincentive, uint256 _incen_mult) public onlyOwner
    {
        IM.baseincentive=_baseincentive;
        IM.incen_mult=_incen_mult;
    }
struct Record {
        string data;
        uint256 timestamp;
    }
    
    mapping(uint256 => Record) private records;
    uint256 private recordCount;
    
    event RecordAdded(uint256 indexed recordId, string data, uint256 timestamp);
    
    function addRecord(string memory data) public onlyOwner 
    {
        records[recordCount] = Record(data, block.timestamp);
        emit RecordAdded(recordCount, data, block.timestamp);
        recordCount++;
    }
    
    function getRecord(uint256 recordId) public view returns (string memory, uint256) 
    {
        require(recordId < recordCount, "Invalid record ID");
        Record memory record = records[recordId];
        return (record.data, record.timestamp);
    }
    
    function getRecordCount() public view returns (uint256) 
    {
        return recordCount;
    }
    
    function updateRecordData(uint256 recordId, string memory newData) public onlyOwner 
    {
        require(recordId < recordCount, "Invalid record ID");
        records[recordId].data = newData;
    }
    
    function updateRecordTimestamp(uint256 recordId, uint256 newTimestamp) public onlyOwner 
    {
        require(recordId < recordCount, "Invalid record ID");
        records[recordId].timestamp = newTimestamp;
    }
    mapping(address => bool) public eligibleForRewards;//Indicates whether the address is eligible for reward or not
    uint256 public reward;
    event ObservationRewarded(address indexed user, uint256 reward);
    constructor(uint256 _RewardInEther) 
    {
        reward = _RewardInEther * 1 ether; // Convert to wei
    }
    enum Pollutionstatus{Polluted,Clean}

    struct Observation {
        address observer;
        string activity;
        uint256 timestamp;
        Pollutionstatus status;
    }
    Observation public userobservation;
    mapping(uint => Observation) public observations;
    uint public observationCount;
    
    event NewObservation(uint observationId, address observer, string activity, uint timestamp);
    
    function addObservation(string memory _activity, Pollutionstatus _status) public
     {
        userobservation.status= _status;
        uint observationId = observationCount++;
        observations[observationId] = Observation(msg.sender, _activity, block.timestamp, userobservation.status);

        emit NewObservation(observationId, msg.sender, _activity, block.timestamp);
        userObservationCount[msg.sender]++;//Update the userobservartion count
    }
      
   function validateobservation(bool ispolluted, bool isclean, bool isvalid) public 
    {
        if (
            MP.pH <= Threshold.pHthreshold ||
            MP.turb <= Threshold.turbthreshold ||
            MP.tds <= Threshold.tdsthreshold || 
            MP.DO<= Threshold.DOthreshold ||
            MP.SM<= Threshold.SMthreshold ||
            MP.temp<=Threshold.tempthreshold
        )//Condition to check whether the observation provided by the user is accurate or not
         {
            isvalid= true;
            eligibleForRewards[msg.sender] = true;
            emit ObservationRewarded(msg.sender, reward);
        }
 else if (MP.pH > Threshold.pHthreshold ||
            MP.turb > Threshold.turbthreshold ||
            MP.tds > Threshold.tdsthreshold || 
            MP.DO > Threshold.DOthreshold ||
            MP.SM > Threshold.SMthreshold ||
            MP.temp > Threshold.tempthreshold
        )// Condition to check whether the wetland is clean
        {
            isclean=true;
            eligibleForRewards[msg.sender] = true;
            emit ObservationRewarded(msg.sender, reward);
        }
        else 
        {
            isvalid=false;
        }
        //Calculate the incentive based on the observation count 
         uint256 userIncentive = IM.baseincentive + userObservationCount[msg.sender] * IM.incen_mult;
    }
    function claimReward() external 
    {
        require(eligibleForRewards[msg.sender], "User is not eligible for rewards");
        // Transfer rewards to the user
     payable(msg.sender).transfer(reward);

        eligibleForRewards[msg.sender] = false; // Mark the user as claimed
    }
}
