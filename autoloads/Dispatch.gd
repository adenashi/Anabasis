extends Node
## Autoload that holds all signals for the game's Message Bus
##
##
##

## [br] Emitters: 
## [br] Subscribers: 


#region Signals

#region Settings

## [br] Emitters: [SceneTransitioner]
## [br] Subscribers: [GameStarter]
signal ShowAsi

#endregion

#region Tutorial

## [br] Emitters: [SettingsMenuController]
## [br] Subscribers: [TutorialController]
signal ToggleTutorial(on : bool)

## [br] Emitters: [GameManager]
## [br] Subscribers: [TutorialController]
signal FirstStageReached

## [br] Emitters: [TutorialController]
## [br] Subscribers: [GameManager]
signal ReadyToStartFirstStage

## [br] Emitters: [PlayValidator]
## [br] Subscribers: [TutorialController]
signal RunSelected

## [br] Emitters: [PlayValidator]
## [br] Subscribers: [TutorialController]
signal SequenceSelected

## [br] Emitters: [PlayValidator]
## [br] Subscribers: [TutorialController]
signal InvalidCardsSelected

## [br] Emitters: [PlayValidator]
## [br] Subscribers: [TutorialController]
signal PlayerAttacked

## [br] Emitters: [CombatManager]
## [br] Subscribers: [TutorialController]
signal EnemyAttacked

#endregion

#region HUD Updates

## [br] Emitters: [PlayerController]
## [br] Subscribers: [PlayerHUD]
signal UpdatePlayerHealth(max : int, value : int)

## [br] Emitters: [CombatManager], [PlayerController]
## [br] Subscribers: [PlayerHUD]
signal UpdatePlayerDefense(max : int, value : int)

## [br] Emitters: [PlayValidator], [CombatManager]
## [br] Subscribers: [PlayerHUD]
signal UpdatePlayerAttack(amount : int)

## [br] Emitters: [BaseEnemy]
## [br] Subscribers: [EnemyHUD]
signal UpdateEnemyHealth(max : int, value : int)

## [br] Emitters: [CombatManager], [BaseEnemy]
## [br] Subscribers: [EnemyHUD]
signal UpdateEnemyDefense(max : int, value : int)

## [br] Emitters: [GM]
## [br] Subscribers: [HUDController]
signal UpdateLevel(newLevel : int)

## [br] Emitters: [GM]
## [br] Subscribers: [HUDController]
signal UpdateGameTime(time : int)

## [br] Emitters: [GM]
## [br] Subscribers: [HUDController]
signal UpdateMoves(newMoves : int)

## [br] Emitters: [GM]
## [br] Subscribers: [HUDController]
signal UpdateScore(newScore : int) 

## [br] Emitters: [HandController]
## [br] Subscribers: [HUDController]
signal ShowSortButtons

## [br] Emitters: [HandController]
## [br] Subscribers: [HUDController]
signal HideSortButtons

## [br] Emitters: 
## [br] Subscribers: [HUDController]
signal ShowActionButtons

## [br] Emitters: 
## [br] Subscribers: [HUDController]
signal HideActionButtons

## [br] Emitters: [DeckManager]
## [br] Subscribers: [HUDController]
signal UpdateDeckCount(count : int)

## [br] Emitters: [DeckManager]
## [br] Subscribers: [HUDController]
signal UpdateDiscardCount(count : int)

#endregion

#region Card Interactions

## [br] Emitters: [BaseCard]
## [br] Subscribers: [HandController]
signal MouseEnteredCard(card : BaseCard)

## [br] Emitters: [BaseCard]
## [br] Subscribers: [HandController]
signal MouseExitedCard(card : BaseCard)

## [br] Emitters: [HUDController]
## [br] Subscribers: [HandController]
signal SortCardsBySuit

## [br] Emitters: [HUDController]
## [br] Subscribers: [HandController]
signal SortCardsByRank

## [br] Emitters: [BaseCard]
## [br] Subscribers: [DeckManager]
signal DiscardCard(card : BaseCard)

## [br] Emitters: [BaseCard]
## [br] Subscribers: [PlayValidator]
signal CardSelected(card : BaseCard)

## [br] Emitters: [BaseCard]
## [br] Subscribers: [PlayValidator]
signal CardDeselected(card : BaseCard)

## [br] Emitters: [HUDController]
## [br] Subscribers: [PlayValidator], [DeckManager]
signal PlaySelectedCards

## [br] Emitters: [HUDController]
## [br] Subscribers: [PlayValidator], [DeckManager]
signal DiscardSelectedCards

#endregion

#region Gameplay

## [br] Emitters: [CombatManager]
## [br] Subscribers: [DeckManager]
signal DealCardsToPlayer(quantity : int)

## [br] Emitters: [DeckManager]
## [br] Subscribers: [GM]
signal DeckReshuffled

## [br] Emitters: [StageManager]
## [br] Subscribers: [CombatManager]
signal SpawnNewEnemy

## [br] Emitters: [CombatManager]
## [br] Subscribers: [StageManager], [EnemyHUD]
signal PlaceEnemy(enemy : EnemyData)

## [br] Emitters: [PlayValidator]
## [br] Subscribers: [GM]
signal PlayerMove

## [br] Emitters: [PlayValidator]
## [br] Subscribers: [CombatManager]
signal PerformAttack(cards : Array[BaseCard])

## [br] Emitters: [PlayValidator]
## [br] Subscribers: [CombatManager]
signal AddDefense(cards : Array[BaseCard])

## [br] Emitters: [PlayValidator]
## [br] Subscribers: [CombatManager]
signal DoAttackAndDefense(cards : Array[BaseCard])

## [br] Emitters: [CombatManager]
## [br] Subscribers: [PlayValidator]
signal EndPlayerTurn

## [br] Emitters: [PlayValidator]
## [br] Subscribers: [CombatManager]
signal StartEnemyTurn

## [br] Emitters: [CombatManager]
## [br] Subscribers: [GM]
signal EnemyDied

## [br] Emitters: [PlayerController]
## [br] Subscribers: [GM]
signal PlayerDied

## [br] Emitters: [CombatManager]
## [br] Subscribers: [GM]
signal AddPoints(points : int)

## [br] Emitters: [StageManager]
## [br] Subscribers: [GM]
signal AllStagesCleared

#endregion

#endregion


## [br] Emitters: 
## [br] Subscribers: 
