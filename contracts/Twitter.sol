// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface IProfile {
    struct UserProfile {
        string displayName;
        string bio;
    }

    function getProfile(address _user) external view returns(UserProfile memory);
}

contract Twitter is Ownable{
    uint16 public MAX_TWEET_LENGTH = 280;

    struct Tweet {
        uint256 id;
        address author;
        string content;
        uint256 timestamp;
        uint256 likes;
    }

    mapping(address => Tweet[]) public tweets;

    IProfile profileContract;
    
    event TweetCreated(uint256 id, address author, string content, uint256 timestamp);
    event TweetLiked(address liker, address tweetAuthor, uint256 tweetId, uint256 newLikeCount);
    event TweetUnliked(address unliker, address tweetAuthor, uint256 tweetId, uint256 newLikeCount);

    modifier onlyRegistered() {
        IProfile.UserProfile memory userProfileTemp = profileContract.getProfile(msg.sender);
        require(bytes(userProfileTemp.displayName).length > 0, "USER NOT REGISTERED");
        _;
    }

    constructor(address _profileContract) Ownable(msg.sender){
        profileContract = IProfile(_profileContract);
    }

    function changeTweetLength(uint16 newTweetLength) public onlyOwner {
        MAX_TWEET_LENGTH = newTweetLength;
    }

    function getTotalLikes(address _author) external view returns (uint256) {
        uint256 totalLikes;
        
        for (uint256 i = 0; i < tweets[_author].length; i++){
            totalLikes += tweets[_author][i].likes;
        }

        return totalLikes;
    }

    function createtweet(string memory _tweet) public onlyRegistered {
        require(bytes(_tweet).length <= MAX_TWEET_LENGTH, "You shall not pass!");

        Tweet memory newTweet = Tweet({
            id: tweets[msg.sender].length,
            author: msg.sender,
            content: _tweet,
            timestamp: block.timestamp,
            likes: 0
        });

        tweets[msg.sender].push(newTweet);

        emit TweetCreated(newTweet.id, newTweet.author, newTweet.content, newTweet.timestamp);
    }

    function likeTweet(address author, uint256 id) external onlyRegistered {
        require(tweets[author][id].id == id, "Tweet Does Not Exist");

        tweets[author][id].likes++;

        emit TweetLiked(msg.sender, author, id, tweets[author][id].likes);
    }

    function unlikeTweet(address author, uint256 id) external onlyRegistered {
        require(tweets[author][id].id == id, "Tweet Does Not Exist");
        require(tweets[author][id].likes > 0, "Tweet Has No Likes");

        tweets[author][id].likes--;

        emit TweetUnliked(msg.sender, author, id, tweets[author][id].likes);
    }

    function getTweet(uint256 _i) public view returns(Tweet memory){
        return tweets[msg.sender][_i];
    }

    function getAllTweets(address _owner) public view returns(Tweet[] memory){
        return tweets[_owner];
    }
}