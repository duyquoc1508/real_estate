pragma solidity >=0.4.21 <0.7.0;
pragma experimental ABIEncoderV2;

import "./SafeMath.sol";
import "./RoleBasedAcl.sol";


/**
 * @title RealEstate
 * @dev Real estate management and transaction
 */

contract RealEstate is RoleBasedAcl {
	using SafeMath for uint256;
	// ------------------------------ Variables ------------------------------
	// name of token
	string public constant name = "Dapp Real Estate";
	// string public symbol = "DRE";
	// string public standard = "Real Estate v1.0";
	// number of certificate (token id)
	uint256 public certificateCount;
	// State of certificate
	enum State { Pendding, Activated, Selling } //sate of token Pendding: 0, Activated: 1, Selling: 2

	struct LandLot {
		string location;
		string purposeOfUse;
		string timeOfUse;
		string originOfUse;
		uint8 landLotNo;
		uint8 mapSheetNo;
		uint8 area;
	}

	struct House {
		uint8 level;
		uint8 constructionArea;
		string location;
		string houseType;
		string apartmentName;
		string floorArea;
		string formOfOwn;
		string timeOfUse;
	}

	struct Certificate {
		LandLot landLot;
		House house;
		string otherConstruction;
		string prodForestIsArtificial;
		string perennialTree;
		string notice;
	}

	// mapping token to owners
	mapping(uint256 => address[]) tokenToOwners;
	// mapping token to owner approved (activate || sell)
	mapping(uint256 => address[]) tokenToApprovals;
	// mapping token to state of token
	mapping(uint256 => State) public tokenToState; // Default: 0 => 'Pendding'
	// mapping token to notary
	mapping(uint256 => address) public tokenToNotary;
	// ------------------------------ Events ------------------------------
	event newCertificate(
		LandLot landLot,
		House house,
		string ortherConstruction,
		string prodForestIsArtificial,
		string perennialTree,
		string notice,
		address notary
	);

	event OwnerActivate(uint256 idCertificate, address owner);

	event Activated(uint256 idCertificate);

	// ------------------------------ Modifiers ------------------------------

	modifier onlyActivated(uint256 _id) {
		require(isActivated(_id), "RealEstate: Please activate first");
		_;
	}

	modifier onlySelling(uint256 _id) {
		require(isSelling(_id), "RealEstate: The certificate doesn't allow for sale");
		_;
	}

	modifier onlyOwnerOf(uint256 _id) {
		require(
			_checkExitInArray(tokenToOwners[_id], msg.sender),
			"RealEstate: You're not owner of certificate"
		);
		_;
	}

	// ------------------------------ View functions ------------------------------

	/**
	 * @param _id id of certificate
	 * @return {address[]} list owner of certificate
	 */
	function getAllOwners(uint256 _id) public view returns (address[] memory) {
		return tokenToOwners[_id];
	}

	/**
	 * @param _id id of certificate
	 * @return {address[]} list owner approved
	 */
	function getAllApproved(uint256 _id) public view returns (address[] memory) {
		return tokenToApprovals[_id];
	}

	// ------------------------------ Core public functions ------------------------------

	/**
	 * @notice create a new certificate with a struct
	 */
	function createCertificate(
		LandLot memory _landLot,
		House memory _house,
		string memory _ortherConstruction,
		string memory _prodForestIsArtificial,
		string memory _perennialTree,
		string memory _notice,
		address[] memory _owners
	) public {
		// require owner not to be a notary
		require(
			!_checkExitInArray(_owners, msg.sender),
			"RealEstate: The notary is not the owner of certificate"
		);
		certificateCount = certificateCount.add(1);
		Certificate(
			_landLot,
			_house,
			_ortherConstruction,
			_prodForestIsArtificial,
			_perennialTree,
			_notice
		);
		tokenToOwners[certificateCount] = _owners;
		tokenToNotary[certificateCount] = msg.sender;
		emit newCertificate(
			_landLot,
			_house,
			_ortherConstruction,
			_prodForestIsArtificial,
			_perennialTree,
			_notice,
			msg.sender
		);
	}

	/**
	 * @notice Activate certificate
	 * @dev Require msg.sender is owner of certification
	 */
	function activate(uint256 _id) public onlyOwnerOf(_id) {
		// Require msg.sender do not activated
		require(
			!_checkExitInArray(tokenToApprovals[_id], msg.sender),
			"RealEstate: Account already approved"
		);
		// store msg.sender to list approved
		tokenToApprovals[_id].push(msg.sender);
		emit OwnerActivate(_id, msg.sender);
		// if all owner approved => set state of certificate to 'activated'
		if (tokenToApprovals[_id].length == tokenToOwners[_id].length) {
			tokenToState[_id] = State.Activated;
			// set user approve to null
			delete tokenToApprovals[_id];
			emit Activated(_id);
		}
	}

	/**
	 * @notice Activate sale
	 * @dev require current token state is 'Activated'
	 * require msg.sender is owner of certification
	 */
	function activateSale(uint256 _id) public onlyActivated(_id) onlyOwnerOf(_id) {
		// require msg.sender dot not activated
		require(
			!_checkExitInArray(tokenToApprovals[_id], msg.sender),
			"RealEstate: Account already approved"
		);
		// store msg.sender to list approved
		tokenToApprovals[_id].push(msg.sender);
		// if all owner approved => set state of certificate to 'selling'
		if (tokenToApprovals[_id].length == tokenToOwners[_id].length) {
			tokenToState[_id] = State.Selling;
		}
	}

	/**
	 * @notice check state of certificate is 'Activated'
	 * @param _id id of certificate
	 * @return bool
	 */
	function isActivated(uint256 _id) public view returns (bool) {
		return tokenToState[_id] == State.Activated;
	}

	/**
	 * @notice check state of certificate is 'Selling'
	 * @param _id id of certificate
	 * @return bool
	 */
	function isSelling(uint256 _id) public view returns (bool) {
		return tokenToState[_id] == State.Selling;
	}

	// ------------------------------ Helper functions (internal functions) ------------------------------

	/**
	 * @notice Check list address include single address
	 * @param _array list address
	 * @param _user	address want to check
	 * @return bool
	 */
	function _checkExitInArray(address[] memory _array, address _user)
		internal
		pure
		returns (bool)
	{
		uint256 _arrayLength = _array.length;
		for (uint8 i = 0; i < _arrayLength; i++) {
			if (_user == _array[i]) {
				return true;
			}
		}
		return false;
	}
}
