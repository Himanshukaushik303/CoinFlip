// SPDX-License-Identifier: GPL-3.0

//declaring solidity version
pragma solidity >=0.8.0 <0.9.0;


//contract object
contract CoinFlip {
    int SIZE  = 10;  // Maximum number of users

    //struct for bet details
    struct betDetails{
        int bet;        //guess the outcome 0 or 1
        int amount;     //amount to put in bet
        bool flag;      // bet is placed or not
    }

//mappings 
    mapping(int => int) userBalance; // For user's balance
    mapping(int => betDetails) userBets;

    // Initialize all user with 100 points
    function initializeUser() public{
        for(int i=0; i<SIZE; i++){
            userBalance[i] = 100;
        }
    }

    // Return User Balance 
    function showUserBalance(int userId) public view returns(int){
        if(userId>=0 && userId<SIZE)
            return userBalance[userId];
        else return -1;
    }

    //place bets
    function placeBet(int userId, int amount, int bet) public returns(bool){
        if(userId<0 || userId>=SIZE) // for Invalid ID
            return false;
        if(userBalance[userId]<amount || userBalance[userId]==0) // for low balance and 0 balance
            return false;
        if(userBets[userId].flag) // for already participated into bet game
            return false;

        // Deduct the user's balance
        userBalance[userId] -= amount;
        // Add their bet
        userBets[userId].amount = amount;
        userBets[userId].bet = bet;
        userBets[userId].flag = true;

        return true;       
    }

    // Using Harmony VRF for random number genration
    function vrf() public view returns (bytes32 result) {
    uint[1] memory bn;
    bn[0] = block.number;
    assembly {
      let memPtr := mload(0x40)
      if iszero(staticcall(not(0), 0xff, bn, 0x20, memPtr, 0x20)) {
        invalid()
      }
    result := mload(memPtr)
    }
    return result;
    }

   


    // Conclude all bets with win/loss
    function rewardBet() public {
        int outcome = 1;
        uint randNumber = uint(vrf());
        if(randNumber%2 == 0)
            outcome = 0;
        else 
            outcome =1;
            
        // final results
        for(int i=0; i<SIZE; i++){
            if(userBets[i].flag && userBets[i].bet == outcome)
            {
                userBalance[i] += (2*userBets[i].amount);
            }
                userBets[i].flag = false;
            
        }
    }

}
