# Marketplace Smart Contract

A decentralized blockchain marketplace that enables users to list products for sale and purchase items directly from sellers with immediate payment settlement.

## Overview

This Solidity smart contract implements a simple yet effective decentralized marketplace where:

- Sellers can list products with details and prices
- Buyers can purchase products, with funds transferred directly to sellers
- Sellers can update or remove their product listings
- Users can view their purchase history and listing history

## Features

- **Product Listing**: Sellers can create listings with name, description, and price
- **Direct Purchase**: Payments are transferred immediately to sellers upon purchase
- **Product Management**: Sellers can update or remove their listings
- **Transaction History**: Users can view their selling and purchasing activity
- **Event Logging**: All major actions emit events for off-chain tracking

## Function Summary

| Function                | Description                                         |
| ----------------------- | --------------------------------------------------- |
| `listProduct`           | Creates a new product listing                       |
| `buyProduct`            | Purchases a product and transfers payment to seller |
| `updatePoduct`          | Updates details of an existing product              |
| `removeProduct`         | Removes a product from the marketplace              |
| `getSellerProducts`     | Returns all products listed by the caller           |
| `getBuyerPurchases`     | Returns all products purchased by the caller        |
| `getProduct`            | Returns details of a specific product               |
| `getMarketplaceProduct` | Returns the complete Product struct for a product   |

## Usage

### For Sellers

1. Call `listProduct` with name, description, and price to list a new product
2. Use `updatePoduct` to modify product details if needed
3. Use `removeProduct` to take down a listing
4. Call `getSellerProducts` to view all your listed products

### For Buyers

1. Call `buyProduct` with the product ID and send the required ETH amount
2. Use `getBuyerPurchases` to view your purchase history
3. Call `getProduct` to check details of any product

## Security Considerations

- The contract includes basic validation checks
- Product availability is managed through flags rather than deletions
- Only the original seller can update or remove their products
- Sellers cannot purchase their own products
- The contract owner has no special privileges over user transactions

## Future Improvements

- Add an escrow system for safer transactions
- Implement product categories and search functionality
- Add ratings and review system
- Support for bulk listing and purchasing
- Fee structure for marketplace operation
