(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-already-paid (err u103))
(define-constant err-insufficient-amount (err u104))
(define-constant err-invalid-split (err u105))
(define-constant err-already-member (err u106))
(define-constant err-not-member (err u107))
(define-constant err-bill-settled (err u108))
(define-constant err-already-exists (err u109))

(define-data-var group-nonce uint u0)
(define-data-var bill-nonce uint u0)

(define-map groups
  uint
  {
    name: (string-ascii 50),
    creator: principal,
    created-at: uint,
    member-count: uint,
    active: bool
  }
)

(define-map group-members
  {group-id: uint, member: principal}
  {
    joined-at: uint,
    is-active: bool
  }
)

(define-map bills
  uint
  {
    group-id: uint,
    description: (string-ascii 100),
    total-amount: uint,
    paid-by: principal,
    split-count: uint,
    amount-per-person: uint,
    created-at: uint,
    settled: bool
  }
)

(define-map bill-payments
  {bill-id: uint, member: principal}
  {
    amount-owed: uint,
    amount-paid: uint,
    paid: bool,
    paid-at: uint
  }
)

(define-map user-balances
  {group-id: uint, user: principal}
  uint
)

(define-public (create-group (name (string-ascii 50)))
  (let
    (
      (group-id (+ (var-get group-nonce) u1))
      (current-block stacks-block-height)
    )
    (asserts! (> (len name) u0) err-invalid-split)
    (map-set groups group-id {
      name: name,
      creator: tx-sender,
      created-at: current-block,
      member-count: u1,
      active: true
    })
    (map-set group-members {group-id: group-id, member: tx-sender} {
      joined-at: current-block,
      is-active: true
    })
    (var-set group-nonce group-id)
    (ok group-id)
  )
)

(define-public (add-member (group-id uint) (member principal))
  (let
    (
      (group (unwrap! (map-get? groups group-id) err-not-found))
      (existing-member (map-get? group-members {group-id: group-id, member: member}))
      (caller-membership (unwrap! (map-get? group-members {group-id: group-id, member: tx-sender}) err-unauthorized))
      (current-block stacks-block-height)
    )
    (asserts! (get is-active caller-membership) err-unauthorized)
    (asserts! (is-none existing-member) err-already-member)
    (map-set group-members {group-id: group-id, member: member} {
      joined-at: current-block,
      is-active: true
    })
    (map-set groups group-id (merge group {member-count: (+ (get member-count group) u1)}))
    (ok true)
  )
)

(define-public (create-bill (group-id uint) (description (string-ascii 100)) (total-amount uint))
  (let
    (
      (bill-id (+ (var-get bill-nonce) u1))
      (group (unwrap! (map-get? groups group-id) err-not-found))
      (membership (unwrap! (map-get? group-members {group-id: group-id, member: tx-sender}) err-not-member))
      (member-count (get member-count group))
      (amount-per-person (/ total-amount member-count))
      (current-block stacks-block-height)
    )
    (asserts! (get is-active membership) err-not-member)
    (asserts! (> total-amount u0) err-insufficient-amount)
    (asserts! (> member-count u0) err-invalid-split)
    (map-set bills bill-id {
      group-id: group-id,
      description: description,
      total-amount: total-amount,
      paid-by: tx-sender,
      split-count: member-count,
      amount-per-person: amount-per-person,
      created-at: current-block,
      settled: false
    })
    (var-set bill-nonce bill-id)
    (ok bill-id)
  )
)

(define-public (pay-bill (bill-id uint))
  (let
    (
      (bill (unwrap! (map-get? bills bill-id) err-not-found))
      (group-id (get group-id bill))
      (membership (unwrap! (map-get? group-members {group-id: group-id, member: tx-sender}) err-not-member))
      (amount-owed (get amount-per-person bill))
      (existing-payment (map-get? bill-payments {bill-id: bill-id, member: tx-sender}))
      (current-block stacks-block-height)
    )
    (asserts! (not (get settled bill)) err-bill-settled)
    (asserts! (get is-active membership) err-not-member)
    (asserts! (is-none existing-payment) err-already-paid)
    (try! (stx-transfer? amount-owed tx-sender (get paid-by bill)))
    (map-set bill-payments {bill-id: bill-id, member: tx-sender} {
      amount-owed: amount-owed,
      amount-paid: amount-owed,
      paid: true,
      paid-at: current-block
    })
    (ok true)
  )
)

(define-public (settle-bill (bill-id uint))
  (let
    (
      (bill (unwrap! (map-get? bills bill-id) err-not-found))
    )
    (asserts! (is-eq tx-sender (get paid-by bill)) err-unauthorized)
    (asserts! (not (get settled bill)) err-bill-settled)
    (map-set bills bill-id (merge bill {settled: true}))
    (ok true)
  )
)

(define-public (leave-group (group-id uint))
  (let
    (
      (membership (unwrap! (map-get? group-members {group-id: group-id, member: tx-sender}) err-not-member))
      (group (unwrap! (map-get? groups group-id) err-not-found))
    )
    (asserts! (get is-active membership) err-not-member)
    (map-set group-members {group-id: group-id, member: tx-sender} (merge membership {is-active: false}))
    (map-set groups group-id (merge group {member-count: (- (get member-count group) u1)}))
    (ok true)
  )
)

(define-read-only (get-group (group-id uint))
  (ok (map-get? groups group-id))
)

(define-read-only (get-bill (bill-id uint))
  (ok (map-get? bills bill-id))
)

(define-read-only (get-payment-status (bill-id uint) (member principal))
  (ok (map-get? bill-payments {bill-id: bill-id, member: member}))
)

(define-read-only (is-group-member (group-id uint) (member principal))
  (match (map-get? group-members {group-id: group-id, member: member})
    membership (ok (get is-active membership))
    (ok false)
  )
)

(define-read-only (get-group-member-info (group-id uint) (member principal))
  (ok (map-get? group-members {group-id: group-id, member: member}))
)

(define-read-only (get-user-balance (group-id uint) (user principal))
  (ok (default-to u0 (map-get? user-balances {group-id: group-id, user: user})))
)

(define-read-only (get-group-nonce)
  (ok (var-get group-nonce))
)

(define-read-only (get-bill-nonce)
  (ok (var-get bill-nonce))
)
