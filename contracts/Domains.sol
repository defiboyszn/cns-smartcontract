// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import {StringUtils} from "./libraries/StringUtils.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

import "hardhat/console.sol";

contract Domains is ERC721URIStorage {
    address payable public owner;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    error Unauthorized();
    error AlreadyRegistered();
    error InvalidName(string name);
    event Transfer(string name, address newOwner);

    string public tld;

    string svgPartOne =
        '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="270" height="270" viewBox="0 0 270 270" fill="none"><g clip-path="url(#clip0_4_2)"><path d="M0 0H270V270H0V0Z" fill="url(#paint0_linear_4_2)"/><rect x="20" y="24" width="70.05" height="62.03" fill="url(#pattern0)"/><text x="32.5" y="231" font-size="27" fill="#fff" filter="url(#A)" font-family="Plus Jakarta Sans,DejaVu Sans,Noto Color Emoji,Apple Color Emoji,sans-serif" font-weight="bold">';
    string svgPartTwo =
        '</text></g><defs><pattern id="pattern0" patternContentUnits="objectBoundingBox" width="1" height="1"><use xlink:href="#image0_4_2" transform="matrix(0.00655934 0 0 0.00740741 -0.0083485 0)"/></pattern><linearGradient id="paint0_linear_4_2" x1="0" y1="0" x2="270" y2="270" gradientUnits="userSpaceOnUse"><stop stop-color="#191818"/><stop offset="1" stop-color="#AD28FF" stop-opacity="0.99"/></linearGradient><clipPath id="clip0_4_2"><rect width="270" height="270" fill="white"/></clipPath><image id="image0_4_2" width="155" height="135" xlink:href="data:image/png;base64,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"/></defs></svg>';

    string avatar = 'PHN2ZyB3aWR0aD0iMTk3IiBoZWlnaHQ9IjE5NyIgdmlld0JveD0iMCAwIDE5NyAxOTciIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiPgo8cmVjdCB3aWR0aD0iMTk3IiBoZWlnaHQ9IjE5NyIgZmlsbD0idXJsKCNwYWludDBfbGluZWFyXzVfNCkiLz4KPHJlY3QgeD0iNjMiIHk9IjY3IiB3aWR0aD0iNzAuMDUiIGhlaWdodD0iNjIuMDMiIGZpbGw9InVybCgjcGF0dGVybjApIi8+CjxkZWZzPgo8cGF0dGVybiBpZD0icGF0dGVybjAiIHBhdHRlcm5Db250ZW50VW5pdHM9Im9iamVjdEJvdW5kaW5nQm94IiB3aWR0aD0iMSIgaGVpZ2h0PSIxIj4KPHVzZSB4bGluazpocmVmPSIjaW1hZ2UwXzVfNCIgdHJhbnNmb3JtPSJtYXRyaXgoMC4wMDY1NTkzNCAwIDAgMC4wMDc0MDc0MSAtMC4wMDgzNDg1IDApIi8+CjwvcGF0dGVybj4KPGxpbmVhckdyYWRpZW50IGlkPSJwYWludDBfbGluZWFyXzVfNCIgeDE9Ijk4LjUiIHkxPSIwIiB4Mj0iOTguNSIgeTI9IjE5NyIgZ3JhZGllbnRVbml0cz0idXNlclNwYWNlT25Vc2UiPgo8c3RvcCBzdG9wLWNvbG9yPSIjMjExOTI1Ii8+CjxzdG9wIG9mZnNldD0iMSIgc3RvcC1jb2xvcj0iI0FEMjhGRiIgc3RvcC1vcGFjaXR5PSIwLjk5Ii8+CjwvbGluZWFyR3JhZGllbnQ+CjxpbWFnZSBpZD0iaW1hZ2UwXzVfNCIgd2lkdGg9IjE1NSIgaGVpZ2h0PSIxMzUiIHhsaW5rOmhyZWY9ImRhdGE6aW1hZ2UvcG5nO2Jhc2U2NCxpVkJPUncwS0dnb0FBQUFOU1VoRVVnQUFBSnNBQUFDSENBWUFBQUFCZFN0c0FBQUFDWEJJV1hNQUFBc1RBQUFMRXdFQW1wd1lBQUFBQVhOU1IwSUFyczRjNlFBQUFBUm5RVTFCQUFDeGp3djhZUVVBQUFpY1NVUkJWSGdCN2QzaGRkczJFQWZ3YzE2KzE1bWd5QVJKSnFneVFkTUpLazhRWndMTEU4U2RRTW9FU1NZd000R2RDVVJQRUdjQ0ZHZENEbXVMRkhIQUFhRDcvNzNISjh1aUtCSThnaUFBZ2tRQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBOEtRY1VXSFcybVAzOHRwUHI5eGsvSFRzcDc1Yk43VzkxKzl1dWo0Nk9tb0lKZ2xNNzVhNnRPYnAyazAzYm1wY2VsL1RuTGlOWHJqcDBrMC9iRHhleHBxWFNSSGM5NWQrblE3OUZzOWpLQUovZitMMjc3Yk5VQVRicGZmYXBrbnZiWXAxVXVjM2VtdjFYRW9Td1hZN1B3VHZ0R01TY3QvOWJNTmNrb0Q5ZFZCcldkc2FnODZ0MUVlYnoxbmd1cjJ6NFZZa1pNTnptQjhVeU9aTjcxT3FoVnVaSzV2ZjVJQ3ozU2swVkhBQTlINHZXT0R5MXphLzBmUitSaG00bGZoSVhZRTB0NVg3N1hlazU5aEdsaE0xK0oyK3BQeTAwM3VjbGVVWUtVMHFXMFdzcDdRc0ZXemljcXRON3h3NVcxRFpTUUZ2dUdaNVltRWpMaFFVVkp2ZXFzRm11MU9Nb2ZMZUt3ZkVraXJndG5GSkZhZTNkczcyTjlXQk4zeEpldjZrT3BUTzFYYjJwcmQyc0pVckxENm1HUkFMVy9oQ29hS3p5TTZqOUZZTE5yL3hOWlZsdEsrR1N4OVlOUjNZN0ZGWlZqTm5XMUJkdUpwQ00rQktGeGxlVVgzK2s5NmF3VmI5eGlkV3VzNnRSRDNtSWRtQ3paQWM5ekk0ZDlQTEk4LzkvY1pOSjlUMVJKRFMzaUZGQ3VnK3g0NHBzclRVcFczcTlNNlQ0Vmk1clIxcDJMVmRnL25XeW53WldXNnF5dEJKTzkwS2pDeHJZZVd1eHRiWmR1a3Q3U2x5MVYrV1NzNW00K3EwenQyQjFRNTk2RDg3SVpuZlNkK1M4ak1rZCtMUzlIYm9RNS9lLzVCTWxnc0VRM0xOb1JsOFo4bGJDcGZqNnJpV09yY3Ayb2tkSVJ1U01mMDNXc0VtM2FtM1k3bmFBMVBuNnpPa3IwU2RteUdaTnZGOG83TDArZ2dRa2x0SmNyWmNhcXZ6S3NZZGVQZEZsOXB5dHFlaWxtYTZxaURZZEZUWno2MjAyazZqVDBrdGplSmpER1dFWU5PVHM1OWJTekltNHpvaTJKUXRxWDdMQ2ZNa3VSaERzT25LVmVjMnBhNXN5Sms5Y0N1ZXIvUVZCWno3N3MzdTd6a0gydzJGeTExZGtxdk9yU1U1UG8xZTJzUDNma29DZXROLzg1em1pOXM1UTZzWXZsQitYT2ZXa0NMT2VWeXd0Q1F2OEJ2cUF1N3RTS1g2WDlSdHl4OTArSGRhNm9iRzJQVC9xVExXaCszNndxOHBIRGVmdkp3NnMvK2QzWmdWUTNhbmdMdU5IMm9IakZqblE3aFY1TVdlM3d1NkQ1VDUzaGg3dWNWZHVKZjNGS2QxMDl1QVZwd2djODdaT1BFM1ZMKzdPcmNNZzk5d3JoMGJiSVlPNTNCaXVFRElRNzNPelFkelEvR01tNjQweXBvSXRqeHkxYmw5b0RSMkZ3MUptOTBRYlBrc1NabnZMcFFxNE5qR0JnN1FNd2JCbGsrV09qY1hjSHloOEluU1dhVUtPQVJiUGpuN3VaMVNYRVh2UXh4d0h5a1NnaTJ2TFAzY2ZQWE9XMG9iY0tlMkc4QlFYUFpFc09XVnJaK2JVc0R4d1RLbHRXRXZCRnRlV2Z1NWNjQzVpVy9KUzFtRzQwcDBVY0FoMk9LMEZONEV0dWJURVdYa0FtNUozWDI0cVJnU0JCeUNMYzRudHlPNXpiQUorSTZoQXZjb3VQVmNrVTdBVGI3eEc4R1d4bGVhQVI5d0tldmhEQVVFSElJdGpRM1ZmYmZYUFY4UHh4Y09xZFozMTlwd01PQVFiQW40SzcrR1pzSzNvL0tGUTB0cFRBbzRCRnM2MGlFS2l2QzlPamlIYXlrTkRyalBZeGNOQ0xaRUlvYUVLS1lYY0tucTRveWJCcSswRVd4cHpTcDNZNzJBUzlXTCtiVWRlUElOZ2kydEV0M09vL25LWDY3Q1NWVTFjcmJ2ZElwZ1M4aDM4V2xvcGhMWHhUM3FLVExyYnVHKzZZZTc3aGdhSC9LaGRkTzNUTjNJdWM1dFFUUEZBZWZTbGN1ZXNiMDgrTUZ6SC9yM2ZNdzIyQVEzcVBESWtzWWZ2Wm8yMUIzVk9Ycm0zdk9ucmZmK2Q4M0lyTHNIQTM4YUdwdU42K0o4d01YY0FNVHJ3UzBsbTkwLzVweXpTVG9qOHM1WWtTSi9XeDNuYnRsNmVQaEE0eUZGUXdMODFOL1kwdXo3a004Qy9nYXdtSURqMi80MnV6ZHpMck5KY281Y3VjMkc4cElPNER4NlFQaGlSMHp6VnJiUnd2KzNDdFM1VFc0TWYrREZvUmw4ODFaRE1xYi9Cc0dtWnc1MWJyOU5uRS9hMGVDNDM3TVh3YWJuZ3A2T2h1VHVBeHJCcG1SdWpmTUhZTWlzR1poRlA3ZGN0SUt0SldBYnluT2gwTklNSUdkVDVFK2xLVzgyU1MxcnhYTnRPVnZJR0srU3kvMlc4c3ZST0MvTlBVM2krZmI1dWZ1anhwenQ5TkFNdnFsS2NsUm03Mi9tNjl4YTB0V1N6TlJiQzhXdElhTnRvejVuV1ZMWDFMQnZoL0tYdjQ0MWFuTWZLY0ZZZHp2OE1Qdk4wUGhndm1sR092WkVxYzZOZkNyVkhEWXJacnQ0dlpxaEQzMTZMMGxtZUwyNEQ3bWQvcmkvclIxL1ZPUFd5bTF0OTBqRzEvMk5kdE9walZ2dXhjajZTaDRCdWFJSjNIekhOb0VEdnlGOVRDUGIybTc3angrazkxbmtjaS83Ni9pOHYzRDN3aDlPUFQzZHplKys5MlpnNk5CcmlodmpkZTNYaXhKcXFRRGZPTitRYnRlamx1VE5Wb2E2OUY0blR1K2YvVGY5TXB1a1c0eWg0U3oyRzlYbm1zclJ2aXI5VHZWcCttLzZ3U1k5S29ZR1R5NjVZL2U1elRDdTdSaStLdFVzTTlhVzNxenB2MGtSYkdiZy83enhwUXJrK3hUTmFUUFV1VzJvTG84ZW5LdFc5ZUVUdDZibW1oejFYWWVvclVPRmJiSE53MzlvMTdOdHFBNjhJNG9IbXorTmE1N3VhanE0SDkwNG94cHNDWWRMai9WbDRJcTVCTTJBMkZBZFJaZTk5YVE1V2hCU0R0TWswVkw1ZGVpN0lDWCtnS28ydlo4OW1Fbmk1OWlIUG5jcjJXdjEvRWpwOFRnUzJtV3J5RzdjS1F5bWR6L1lwRmRyVThwQ0t5cHphWDUrVk9jamg3UnpINzY3dmFYOFJ0TzdIMnlETTQxb2FjSlIxQnZiTldjTzl5SERQYUtpOHBId2hwako4L3ZjTS9WWXVtUDQ5MDZDMHRzMVZhd0MycjI0eld4QmdYd2IzTmJxdWJRQlEyLzIxa3ZTZm1sSXlIYnR2Q0ZFOTIvYVBPbHRTTUoyRGJCOGcrclZ3TUszYnJxd0VRbnRmNGR2ei85czArREFYOXZJa2JodHQyT3VKdnplMWsybkZLbjNlejhPYk51bGpVL3ZwVjlPQ3J4T0hBTkJCN1hLODBaRDJTNUllTVYzM1pxTWYzM1lWbnRMdjRZUDRJbmJBNjhMTjBQTml1MTZkbkJhTDZocmFoeEw3OWEvY25uN3hyODJOVjF3QVFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBRUJCL3dKNFdHNisvVHZQekFBQUFBQkpSVTVFcmtKZ2dnPT0iLz4KPC9kZWZzPgo8L3N2Zz4K';

    mapping(uint => string) public names;
    struct Domain {
        address owner;
        string name;
        string image;
        string avatar;
    }

    // Address of the treasury
    address public treasuryAddress;
    mapping(string => Domain) domains;

    constructor(string memory _tld) payable ERC721("Card Name Service", "CNS") {
        owner = payable(msg.sender);
        tld = _tld;
    }

    function register(string calldata name) public payable {
        require(domains[name].owner == address(0));
        if (domains[name].owner != address(0)) revert AlreadyRegistered();
        if (!valid(name)) revert InvalidName(name);
        uint256 _price = price(name);
        require(msg.value >= _price, "Not enough Token to purchase");
        string memory _name = string(abi.encodePacked(name, ".", tld));
        string memory finalSvg = string(
            abi.encodePacked(svgPartOne, _name, svgPartTwo)
        );
        uint256 newRecordId = _tokenIds.current();
        uint256 length = StringUtils.strlen(name);
        string memory strLen = Strings.toString(length);
        string memory json = Base64.encode(
            abi.encodePacked(
                "{"
                '"name": "',
                _name,
                '", '
                '"description": "A domain on the Card name service", '
                '"image": "data:image/svg+xml;base64,',
                Base64.encode(bytes(finalSvg)),
                '", '
                '"length": "',
                strLen,
                '"'
                "}"
            )
        );

        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        _safeMint(msg.sender, newRecordId);
        _setTokenURI(newRecordId, finalTokenUri);
        domains[name].owner = msg.sender;
        domains[name].name = string(abi.encodePacked(name, ".", tld));
        domains[name].image = string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(bytes(finalSvg))
            )
        );
        domains[name].avatar = string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                (avatar)
            )
        );
        names[newRecordId] = name;
        _tokenIds.increment();
    }



    /**
	 * @dev Transfers ownership of a name to a new address. Can only be called by the current owner of the domain.
	 * @param name The name to transfer ownership of.
	 * @param newOwner The address of the new owner.
	 */
	function transfer(string calldata name, address newOwner) public virtual domainOwner(name) {
		require(newOwner != address(0x0), 'cannot set owner to the zero address');
		require(newOwner != address(this), 'cannot set owner to the registry address');

		domains[name].owner = newOwner;
		emit Transfer(name, newOwner);
	}

    function setAvatar(string memory _avatar, string memory name) public {
        require(
            domains[name].owner == owner,
            "You can't set the avatar because it's not yours"
        );
        domains[name].avatar = _avatar;
    }

    function valid(string calldata name) public pure returns (bool) {
        return StringUtils.strlen(name) >= 3 && StringUtils.strlen(name) <= 10;
    }

    function getAllNames() public view returns (string[] memory) {
        string[] memory allNames = new string[](_tokenIds.current());
        for (uint i = 0; i < _tokenIds.current(); i++) {
            allNames[i] = string(abi.encodePacked(names[i], ".", tld));
        }
        return allNames;
    }

    

    // This function will give us the price of a domain based on length
    function price(string calldata name) public pure returns (uint) {
        uint len = StringUtils.strlen(name);
        require(len > 0);
        if (len == 3) {
            return 10 * 10 ** 17;
        } else if (len == 4) {
            return 4 * 10 ** 17;
        } else {
            return 2 * 10 ** 17;
        }
    }

    function getAddress(string calldata name) public view returns (address) {
        return domains[name].owner;
    }

    function getDomain(
        string calldata name
    ) public view returns (Domain memory) {
        return domains[name];
    }


    modifier onlyOwner() {
        require(isOwner());
        _;
    }
    modifier domainOwner(string memory _name) {
        require(
            domains[_name].owner == owner,
            "You are not the domain owner"
        );
        _;
    }

    function setTreasuryAddress(address _address) public onlyOwner {
        treasuryAddress = _address;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == owner;
    }

    function withdraw() public onlyOwner {
        uint amount = address(this).balance;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Failed to withdraw Matic");
    }
}
