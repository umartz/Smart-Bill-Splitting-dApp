# 💰 Smart Bill Splitting dApp

A decentralized application for splitting bills among groups with automatic calculation and on-chain payment confirmations on the Stacks blockchain.

## 🎯 Overview

Smart Bill Splitting dApp enables groups to manage shared expenses transparently. Whether it's restaurant bills, rent payments, or travel costs, this smart contract handles payment aggregation, auto-calculated splits, and on-chain settlement tracking.

## ✨ Features

- 👥 **Group Management**: Create and manage payment groups
- 📝 **Bill Creation**: Add bills with descriptions and total amounts
- 🧮 **Auto-Split Calculation**: Automatically divides bills equally among group members
- 💸 **On-Chain Payments**: Direct STX transfers from payers to bill creator
- ✅ **Payment Tracking**: Track who paid and who still owes
- 🔒 **Settlement Confirmation**: Bill creators can mark bills as settled
- 🚪 **Flexible Membership**: Members can join or leave groups

## 🚀 Getting Started

### Prerequisites

- Clarinet installed
- Stacks wallet

### Installation

```bash
git clone <repository-url>
cd Smart-Bill-Splitting-dApp
clarinet check
```

## 📖 Usage

### Create a Group

```clarity
(contract-call? .Smart-Bill-Splitting-dApp create-group "Weekend Trip")
```

Returns the group ID.

### Add Members to Group

```clarity
(contract-call? .Smart-Bill-Splitting-dApp add-member u1 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)
```

### Create a Bill

```clarity
(contract-call? .Smart-Bill-Splitting-dApp create-bill u1 "Dinner at Restaurant" u1000000)
```

Creates a bill for 1 STX, automatically split among all group members.

### Pay Your Share

```clarity
(contract-call? .Smart-Bill-Splitting-dApp pay-bill u1)
```

Transfers your share directly to the person who paid the bill initially.

### Settle a Bill

```clarity
(contract-call? .Smart-Bill-Splitting-dApp settle-bill u1)
```

Only the bill creator can mark it as settled.

### Leave a Group

```clarity
(contract-call? .Smart-Bill-Splitting-dApp leave-group u1)
```

## 🔍 Read-Only Functions

### Get Group Details

```clarity
(contract-call? .Smart-Bill-Splitting-dApp get-group u1)
```

### Get Bill Details

```clarity
(contract-call? .Smart-Bill-Splitting-dApp get-bill u1)
```

### Check Payment Status

```clarity
(contract-call? .Smart-Bill-Splitting-dApp get-payment-status u1 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)
```

### Check Group Membership

```clarity
(contract-call? .Smart-Bill-Splitting-dApp is-group-member u1 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)
```

## 🏗️ Contract Architecture

- **Groups**: Organizational units for bill splitting
- **Bills**: Individual expenses with auto-calculated splits
- **Payments**: Track individual member contributions
- **Balances**: Monitor outstanding amounts per user per group

## 🔐 Error Codes

- `u100`: Owner only operation
- `u101`: Resource not found
- `u102`: Unauthorized access
- `u103`: Already paid
- `u104`: Insufficient amount
- `u105`: Invalid split configuration
- `u106`: Already a member
- `u107`: Not a member
- `u108`: Bill already settled
- `u109`: Resource already exists

## 🧪 Testing

```bash
clarinet test
```

## 📝 License

MIT

## 🤝 Contributing

Contributions welcome! Please open an issue or submit a pull request.

## 💡 Use Cases

- 🍕 **Restaurant Bills**: Split dinner costs among friends
- 🏠 **Rent & Utilities**: Manage recurring shared housing expenses
- ✈️ **Travel Expenses**: Track and split vacation costs
- 🎉 **Event Costs**: Coordinate group event spending
- 🛒 **Shared Purchases**: Handle communal buying

---

Built with ❤️ on Stacks
