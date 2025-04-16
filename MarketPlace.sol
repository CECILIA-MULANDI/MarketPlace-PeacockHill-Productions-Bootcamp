// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/**
 * @title MarketPlace
 * @dev A decentralized marketplace contract for listing and buying products
 * @notice The workflow is: list product -> buyer sends money -> money is directly transferred to seller
 * @custom:features Product listing, direct purchases with immediate payment to sellers
 */
contract MarketPlace {
    /**
     * @dev Struct to store product information
     * @param id Unique identifier for the product
     * @param name Name of the product
     * @param description Detailed description of the product
     * @param price Price of the product in wei
     * @param seller Address of the seller who listed the product
     * @param isAvailable Boolean indicating if the product is available for purchase
     */
    struct Product {
        uint256 id;
        string name;
        string description;
        uint256 price;
        address payable seller;
        bool isAvailable;
    }

    // Counter to track the total number of products
    uint256 private productCount;

    // Maps product IDs to their corresponding Product structs
    mapping(uint256 => Product) public products;

    // Maps seller addresses to arrays of their product IDs
    mapping(address => uint256[]) private sellerProducts;

    // Maps buyer addresses to arrays of their purchased product IDs
    mapping(address => uint256[]) private buyerPurchases;

    // Contract owner address
    address payable public owner;

    /**
     * @dev Constructor sets the contract deployer as the owner and initializes product count
     */
    constructor() {
        owner = payable(msg.sender);
        productCount = 0;
    }

    // Event declarations

    /**
     * @dev Emitted when a product is listed on the marketplace
     * @param id The product ID
     * @param name The product name
     * @param price The product price
     * @param seller The address of the seller
     */
    event ProductListed(
        uint256 indexed id,
        string name,
        uint256 price,
        address seller
    );

    /**
     * @dev Emitted when a product is sold
     * @param id The product ID
     * @param buyer The address of the buyer
     * @param seller The address of the seller
     * @param price The price at which the product was sold
     */
    event ProductSold(
        uint256 indexed id,
        address buyer,
        address seller,
        uint256 price
    );

    /**
     * @dev Emitted when a product details are updated
     * @param id The product ID
     * @param name The updated product name
     * @param price The updated product price
     */
    event productUpdated(uint256 indexed id, string name, uint256 price);

    /**
     * @dev Emitted when a product is removed from the marketplace
     * @param id The product ID
     */
    event ProductRemoved(uint256 indexed id);

    /**
     * @dev Lists a new product on the marketplace
     * @param _name Name of the product
     * @param _description Description of the product
     * @param _price Price of the product in wei
     * @notice Increments product count and adds the product to the marketplace
     */
    function listProduct(
        string memory _name,
        string memory _description,
        uint256 _price
    ) public {
        // Input validation
        require(_price > 0, "Price must be greater than zero!");
        require(
            bytes(_name).length > 0 && bytes(_description).length > 0,
            "Both the name and the description of the product cannot be empty"
        );

        // Increment product counter
        productCount++;

        // Create and store the product
        products[productCount] = Product({
            id: productCount,
            name: _name,
            description: _description,
            price: _price,
            seller: payable(msg.sender),
            isAvailable: true
        });

        // Add product to seller's product list
        sellerProducts[msg.sender].push(productCount);

        // Emit event
        emit ProductListed(productCount, _name, _price, msg.sender);
    }

    /**
     * @dev Allows a user to buy a product
     * @param _productId ID of the product to purchase
     * @notice Function is payable as it requires ETH to be sent
     * @notice Payment is transferred directly to the seller immediately upon purchase
     */
    function buyProduct(uint256 _productId) public payable {
        // Get the product from storage
        Product storage product = products[_productId];

        // Validation checks
        require(product.id > 0, "Product does not exist");
        require(product.isAvailable, "This product is no longer available!");
        require(
            msg.sender != product.seller,
            "Sellers cannot buy their own products"
        );
        require(
            msg.value >= product.price,
            "You must pay more than the price of this product"
        );

        // Transfer funds directly to the seller
        product.seller.transfer(product.price);

        // Mark product as unavailable
        product.isAvailable = false;

        // Record purchase in buyer's purchase history
        buyerPurchases[msg.sender].push(_productId);

        // Emit event
        emit ProductSold(_productId, msg.sender, product.seller, product.price);
    }

    /**
     * @dev Updates an existing product's details
     * @param _id ID of the product to update
     * @param _name Updated name of the product
     * @param _description Updated description of the product
     * @param _price Updated price of the product
     */
    function updatePoduct(
        uint256 _id,
        string memory _name,
        string memory _description,
        uint256 _price
    ) public {
        // Get the product from storage
        Product storage product = products[_id];

        // Validation checks
        require(product.id > 0, "Product does not exist");
        require(
            product.seller == msg.sender,
            "Only seller can update their product"
        );
        require(product.isAvailable, "Cannot update unavailble product");
        require(_price > 0, "Price must be greater than zero");

        // Update product details
        product.name = _name;
        product.description = _description;
        product.price = _price;

        // Emit event
        emit productUpdated(_id, _name, _price);
    }

    /**
     * @dev Removes a product from the marketplace
     * @param _productId ID of the product to remove
     * @notice This doesn't delete the product, just marks it as unavailable
     */
    function removeProduct(uint256 _productId) public {
        // Get the product from storage
        Product storage product = products[_productId];

        // Validation checks
        require(product.id > 0, "Product does not exist");
        require(
            product.seller == msg.sender,
            "Only seller can remove their product"
        );
        require(product.isAvailable, "Product is already inactive");

        // Mark product as unavailable
        product.isAvailable = false;

        // Emit event
        emit ProductRemoved(_productId);
    }

    /**
     * @dev Retrieves all products listed by the caller
     * @return An array of product IDs
     */
    function getSellerProducts() public view returns (uint256[] memory) {
        return sellerProducts[msg.sender];
    }

    /**
     * @dev Retrieves all products purchased by the caller
     * @return An array of product IDs
     */
    function getBuyerPurchases() public view returns (uint256[] memory) {
        return buyerPurchases[msg.sender];
    }

    /**
     * @dev Retrieves details of a specific product
     * @param _productId ID of the product
     * @return id Product ID
     * @return name Product name
     * @return description Product description
     * @return price Product price
     * @return seller Address of the seller
     * @return isAvailable Boolean indicating if the product is available
     */
    function getProduct(
        uint256 _productId
    )
        public
        view
        returns (
            uint256 id,
            string memory name,
            string memory description,
            uint256 price,
            address seller,
            bool isAvailable
        )
    {
        Product memory product = products[_productId];
        require(product.id > 0, "Product does not exist");

        return (
            product.id,
            product.name,
            product.description,
            product.price,
            product.seller,
            product.isAvailable
        );
    }

    /**
     * @dev Returns the complete Product struct for a given product ID
     * @param _productId ID of the product
     * @return The Product struct
     */
    function getMarketplaceProduct(
        uint256 _productId
    ) public view returns (Product memory) {
        Product memory product = products[_productId];
        require(product.id > 0, "Product does not exist");

        return product;
    }
}
