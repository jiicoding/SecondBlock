package ;

import cards.*;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.events.MouseEvent;

/**
 * ...
 * @author Nico van Pelt
 */
class Player extends Sprite
{
	
	var space:Int = 70; // space in between cards. May be changed to allow more cards in hand.
	
	var startingHand:Bool = true;
	public var activePlayer:Bool = true;
	
	var deck:Array<Card>;
	var hand:Array<Card>;
	var grave:Array<Card>;
	
	var cardsLeft:TextField; //displays the cards left in the deck
	var topCard:Card; //top card of the deck
	var director:Director;
	var main:Main;
	
	public function new(director:Director, main:Main, startingPlayer:Bool) 
	{
		super();
		
		this.director = director;
		this.main = main;
		
		cardsLeft = new TextField();
		addChild(cardsLeft);
		cardsLeft.textColor = 0xFFFFFF;
		cardsLeft.x = 580;
		cardsLeft.y = 550;
		
		deck = new Array<Card>();
		hand = new Array<Card>();
		grave = new Array<Card>();
		
		prepareDeck();
		refreshDeck();
		
		/*
		 * Draw 4 cards as starting hand
		 */
		for (i in 0...4) {
			putInHand(topCard);
		}
		startingHand = false;
		
		if (!startingPlayer) {
			changeActive();
		}
		
		main.addChild(this);
		
	}
	
	/**
	 * Adds cards to deck and shuffles it.
	 * TODO shuffling it
	 */
	private function prepareDeck() {
		var card:Card;
		for ( i in 0...7) { //create 7 of each character card
			card = new Character(0, this);
			card.addEventListener(MouseEvent.CLICK, drawCard);
			deck.push(card);
			card = new Character(1, this);
			card.addEventListener(MouseEvent.CLICK, drawCard);
			deck.push(card);
			card = new Character(2, this);
			card.addEventListener(MouseEvent.CLICK, drawCard);
			deck.push(card);
		}
	}
	
	/**
	 * displays the top card of the deck, if any.
	 */
	public function refreshDeck() {
		if (deck.length > 0) {
			topCard = deck.pop();
			topCard.x = 560;
			topCard.y = 520;
			addChild(topCard);
			removeChild(cardsLeft);
			cardsLeft.text = "" + (deck.length + 1);
			addChild(cardsLeft);
		}
	}
	
	/**
	 * when called, the top card of the deck is added to a player's hand if legal
	 * @param	card
	 */
	private function putInHand(card:Card) {
		if (director.canDraw(this) || startingHand) {
			hand.push(topCard);
			topCard.x = 10 + ((hand.length - 1) * space);
			refreshDeck();
			card.removeEventListener(MouseEvent.CLICK, drawCard);
			card.graphics.beginBitmapFill(Card.cardGraphics[card.cardType]);
			card.graphics.drawRect(0, 0, Card.cardGraphics[card.cardType].width, Card.cardGraphics[card.cardType].height);
			card.addEventListener( MouseEvent.MOUSE_DOWN, dragCard);
		}
	}
	
	/**
	 * make a player the active one or not
	 * TODO make non-active player's cards in hand show the backside
	 */
	public function changeActive() {
		if(activePlayer){
			rotation = 180;
			x = 800;
			y = 600;
			activePlayer = false;
			for (i in 0...hand.length) {
				hand[i].graphics.beginBitmapFill(Card.cardGraphics[3]);
				hand[i].graphics.drawRect(0, 0, Card.cardGraphics[3].width, Card.cardGraphics[3].height);
			}
		} else {
			rotation = 0;
			x = 0;
			y = 0;
			activePlayer = true;
			for (i in 0...hand.length) {
				hand[i].graphics.beginBitmapFill(Card.cardGraphics[hand[i].cardType]);
				hand[i].graphics.drawRect(0, 0, Card.cardGraphics[hand[i].cardType].width, Card.cardGraphics[hand[i].cardType].height);
			}
		}
	}
	
	/**
	 * Called when player tries to draw a card
	 * @param	event
	 */
	public function drawCard( event:MouseEvent ) {
		var card:Card = event.currentTarget;
		putInHand(card);
	}
	
	/**
	 * Called when a player tries to drag a card in their hand
	 * @param	event
	 */
	public function dragCard( event:MouseEvent ) {
		var card:Card = event.currentTarget;
		if(card.owner.activePlayer){
			addChild(card);
			card.startDrag();
			card.addEventListener(MouseEvent.MOUSE_UP, placeCard);
		}
	}
	
	/**
	 * Called when a player releases a card they're dragging
	 * @param	event
	 */
	public function placeCard( event:MouseEvent ) {
		var card:Card = event.currentTarget;
		card.stopDrag();
		if (director.canPlace(card, this)) {
			//TODO place card and execute effect
		} else {
			//return to hand
			card.x = 10 +(hand.indexOf(card) * space);
			card.y = 520;
		}
		card.removeEventListener(MouseEvent.MOUSE_UP, placeCard);
	}

}