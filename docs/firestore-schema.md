# Firestore Schema

## Collections

### chamas
- name: string
- paybill: string
- whatsapp_group_id: string
- leader_id: string
- settings: voting_required, loan_interest_rate, loan_multipliers, lateness_threshold
- total_assets: number
- token_address: string
- eth_wallet: string
- assets: map
- media_urls: map

### members
- chama_id: string
- name: string
- phone: string
- savings: number
- loans: array
- contributions: array
- payment_history: array
- lateness_count: number
- token_balance: number
- ai_tip: string
- cognitive_scores: array
- referrals: array

### transactions
- chama_id, member_id, amount, type, mpesa_id, timestamp, offline: bool

### loanRequests
- chama_id, member_id, amount, max_eligible_amount, votes: array, status, applied_settings

### chats
- chama_id, message, sender_id, timestamp, whatsapp_id

### trades
- chama_id, seller, amount, price, status
