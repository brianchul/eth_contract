// define contract verison
pragma solidity ^0.5.0;

//define a contract
contract MaterialManagement{
    //define a product struct
    struct Product {
        address manufacturer;
        string manufacturerName;
        string serialNumber;
        string productName;
        string manufacturingDate;
        string standard;
        string strenth;
        string amount;
    }
    struct currentOwner{
        address currentAddress;
        string ownerName;
    }
    // map Product variable to variable products
    mapping(bytes32 => Product) public products;
    mapping(bytes32 => currentOwner) public currentProductOwner;
    event TransferProductOwnership(bytes32 indexed p, address indexed account, string indexed companyName);

    constructor() public {
    }

        // hash product information makes easy to verify product
    function concatenateInfoAndHash (
        address a1, string memory s1, string memory s2, string memory s3,
        string memory s4, string memory s5, string memory s6, string memory s7
        ) internal pure returns (bytes32){

        //First, get all values as bytes
        bytes20 b_a1 = bytes20(a1);
        bytes memory b_s1 = bytes(s1);
        bytes memory b_s2 = bytes(s2);
        bytes memory b_s3 = bytes(s3);
        bytes memory b_s4 = bytes(s4);
        bytes memory b_s5 = bytes(s5);
        bytes memory b_s6 = bytes(s6);
        bytes memory b_s7 = bytes(s7);


        //Then calculate and reserve a space for the full string
        string memory s_full = new string(
            b_a1.length + b_s1.length + b_s2.length + b_s3.length + b_s4.length +
            b_s5.length + b_s6.length + b_s7.length
            );
        bytes memory b_full = bytes(s_full);
        uint j = 0;
        uint i;
        for(i = 0; i < b_a1.length; i++){
            b_full[j++] = b_a1[i];
        }
        for(i = 0; i < b_s1.length; i++){
            b_full[j++] = b_s1[i];
        }
        for(i = 0; i < b_s2.length; i++){
            b_full[j++] = b_s2[i];
        }
        for(i = 0; i < b_s3.length; i++){
            b_full[j++] = b_s3[i];
        }
        for(i = 0; i < b_s4.length; i++){
            b_full[j++] = b_s4[i];
        }
        for(i = 0; i < b_s5.length; i++){
            b_full[j++] = b_s5[i];
        }
        for(i = 0; i < b_s6.length; i++){
            b_full[j++] = b_s6[i];
        }
        for(i = 0; i < b_s7.length; i++){
            b_full[j++] = b_s7[i];
        }
        

        //Hash the result and return
        return keccak256(b_full);
    }

    // check if product exist or create new product
    function buildProduct(string memory manufacturerName, string memory serialNumber, string memory productName, string memory manufacturingDate, string memory standard, string memory strenth, string memory amount) public returns (bytes32){
        //Create hash for data and check if it exists. If it doesn't, create the part and return the ID to the user
        bytes32 product_hash = concatenateInfoAndHash(msg.sender, manufacturerName, serialNumber, productName, manufacturingDate, standard, strenth, amount);
        
        require(products[product_hash].manufacturer == address(0), "Product ID already used");

        Product memory new_product = Product(msg.sender, manufacturerName, serialNumber, productName, manufacturingDate, standard, strenth, amount);
        products[product_hash] = new_product;
        return product_hash;
    }

    // add owner address to product
    function addOwnership(bytes32 p_hash, string memory companyName) public returns (bool) {
        address manufacturer;
        manufacturer = products[p_hash].manufacturer;
        
        // if currentProductOwner is not null print "Product was already registered"
        require(currentProductOwner[p_hash].currentAddress == address(0), "Product was already registered");
        // if manufacturer is not sender print "Product was not made by requester"
        require(products[p_hash].manufacturer == msg.sender, "Product was not made by requester");

        currentProductOwner[p_hash].currentAddress = msg.sender;
        currentProductOwner[p_hash].ownerName = companyName;
        emit TransferProductOwnership(p_hash, msg.sender, companyName);
    }


    // change owner address if origional owner transfer product to new owner
    function changeOwnership(bytes32 p_hash, address to, string memory newOwnerName) public returns (bool) {
        require(currentProductOwner[p_hash].currentAddress == msg.sender, "Product is not owned by requester");
        currentProductOwner[p_hash].currentAddress = to;
        currentProductOwner[p_hash].ownerName = newOwnerName;
        // call event TransferProductOwnership
        emit TransferProductOwnership(p_hash, to, newOwnerName);
    }

}

// Saturday 14:00 disguss event logs and query history on blockchain