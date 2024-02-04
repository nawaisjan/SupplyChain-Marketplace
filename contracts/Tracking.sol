// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Tracking{
    enum ShipmentStatus {PENDING,IN_TRANSIT,DELIVERED}


    struct Shipment{
        address sender;
        address receiver;
        uint256 pickupTime;
        uint256 deliveryTime;
        uint256 distance;
        uint256 price;
        ShipmentStatus status;
        bool isPaid;


    }

    mapping(address=>Shipment[])public shipments;
    uint256 public shipmentCount;

    struct TypeShipment {
        address sender;
        address receiver;
        uint256 pickupTime;
        uint256 deliveryTime;
        uint256 distance;
        uint256 priec;
        ShipmentStatus status;
        bool isPaid;
    }

    TypeShipment[] tyepshipments;

    event ShipmentCreate(
        address indexed sender,
        address indexed recevier,
        uint256 pickupTime,
        uint256 distance,
        uint256 price
    );

    event ShipmentIntransit(
        address indexed sender,
        address indexed receiver,
        uint256 pickupTime
    
    );
    event ShipmentDelivered(
        address indexed sender,
        address indexed receiver,
        uint256 deliveryTime
    
    );

    event ShipmentPaid(
        address indexed sender,
        address indexed receiver,
        uint256 amount
    );

    constructor(){
        shipmentCount = 0;
    
    }

    function createShipment(address _receiver,uint256 _pickupTime,uint256 _distance,uint256 _price) public payable {
        require(msg.value == _price,"Payment amoutn must Match the price");
        Shipment memory shipment = Shipment(msg.sender,_receiver,_pickupTime,0,_distance,_price, ShipmentStatus.PENDING,false);

        shipments[msg.sender].push(shipment);
        shipmentCount++;

        tyepshipments.push(
            TypeShipment(
                msg.sender,
                _receiver,
                _pickupTime,
                0,
                _distance,
                _price,
                ShipmentStatus.PENDING,
                false
                
            )
        );

        emit ShipmentCreate(msg.sender, _receiver, _pickupTime, _distance, _price);


        
    }

    function startShipment(address _sender,address _receiver,uint256 _index) public {
        Shipment storage shipment = shipments[_sender][_index];
        TypeShipment storage typeshipment = tyepshipments[_index];

        require(shipment.receiver == _receiver,"Invalid Receiver");
        require(shipment.status == ShipmentStatus.PENDING,"Shipment already in transit");

        shipment.status == ShipmentStatus.IN_TRANSIT;
        typeshipment.status = ShipmentStatus.IN_TRANSIT;

        emit ShipmentIntransit(_sender, _receiver, shipment.pickupTime);

    }

    function completeShipment(address _sender,address _receiver,uint256 _index) public{
        Shipment storage shipment = shipments[_sender][_index];
        TypeShipment storage tyepShipment = tyepshipments[_index];

        require(shipment.receiver == _receiver,"Invalid Recevier");
        require(shipment.status == ShipmentStatus.IN_TRANSIT,"Shipment not in transit");
        require(!shipment.isPaid,"Shipment already paid.");

        shipment.status = ShipmentStatus.DELIVERED;
        tyepShipment.status = ShipmentStatus.DELIVERED;

        tyepShipment.deliveryTime = block.timestamp;
        shipment.deliveryTime= block.timestamp;

        uint256 amount = shipment.price;
        payable(shipment.sender).transfer(amount);
        shipment.isPaid =true;
        tyepShipment.isPaid = true;
        
        emit ShipmentDelivered(_sender, _receiver, shipment.deliveryTime);
        emit ShipmentPaid(_sender, _receiver, amount);

    }

    function getShipmet(address _sender,uint256 _index)public view returns(address,address,uint256,uint256,uint256,uint256,ShipmentStatus,bool){
        Shipment memory shipment = shipments[_sender][_index];
        return(shipment.sender,shipment.receiver,shipment.pickupTime,shipment.deliveryTime,shipment.distance,shipment.price,shipment.status,shipment.isPaid);
    }

    function getShipmentCount(address _sender) public view returns(uint256){
        return shipments[_sender].length;
    }

    function getAllTransactions()public view returns(TypeShipment[] memory){
        return tyepshipments;
    }





}