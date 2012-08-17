/*
	defines.iss

	Hardcoded defines for EVEBot

	- CyberTech

*/

variable string APP_NAME = "EVEBot"
variable string APP_PATH = "EVEBot/EVEBot.iss"
variable string SVN_REVISION = "$Rev$"
variable string APP_HEADURL = "$HeadURL$"

variable string APP_MANIFEST = "https://www.isxgames.com/EVEBot/Trunk/EVEbot/manifest.xml"
variable string APP_MANIFEST_TRUNK = "https://www.isxgames.com/EVEBot/Trunk/EVEbot/manifest-trunk.xml"

variable string AppVersion = "${APP_NAME} Version ${SVN_REVISION.Token[2, " "]}"
variable int VersionNum = ${SVN_REVISION.Token[2, " "]}

#define EVEBOT_DEBUG 0
#define DEBUG_ENTITIES 0

; Do not set this to 1 unless you have downloaded and installed the ISXIM
; extension from http://www.isxgames.com/forums/showthread.php?t=3829
#define USE_ISXIM 0

#define LOG_MINOR 1
#define LOG_STANDARD 2
#define LOG_CRITICAL 3
#define LOG_DEBUG 4

;#define EVENT_ONFRAME OnFrame
#define EVENT_ONFRAME ISXEVE_onFrame

#define WAIT_CARGO_WINDOW 15
#define WAIT_UNDOCK 130

/* If the miner's cargo hold doesn't increase during
 * this period, return to base.  Interval depends on the
 * PulseIntervalInSeconds value used in obj_Miner.Pulse
 * This value is currently set to 2 seconds so 240*2 = 8 minutes
 * The check interval is set high to compensate for slowboating
 */
#define MINER_SANITY_CHECK_INTERVAL 240

/*
 * DEBUG: Slot: MedSlot3  Ballistic Deflection Field II
 *  DEBUG: Group: Shield Hardener  77
 *  DEBUG: Type: Ballistic Deflection Field II  2299
 * DEBUG: Slot: MedSlot1  Heat Dissipation Field II
 *  DEBUG: Group: Shield Hardener  77
 *  DEBUG: Type: Heat Dissipation Field II  2303
 * DEBUG: Slot: MedSlot0  Large Shield Booster II
 *  DEBUG: Group: Shield Booster  40
 *  DEBUG: Type: Large Shield Booster II  10858
 */
#define GROUPID_AFTERBURNER 				46
#define GROUPID_SHIELD_BOOSTER 				40
#define GROUPID_SHIELD_HARDENER 			77
#define GROUPID_ARMOR_REPAIRERS 			62
#define GROUPID_ARMOR_HARDENERS 			328
#define GROUPID_MINING_CRYSTAL 				482
#define GROUPID_FREQUENCY_MINING_LASER 		483
#define GROUPID_SHIELD_TRANSPORTER          41

#define GROUPID_CLOAKING_DEVICE		 		330
#define TYPEID_PROTOTYPE_CLOAKING_DEVICE	11370
#define TYPEID_COVERT_OPS_CLOAKING_DEVICE	11578
#define TYPEID_SMOKESCREEN_CLOAKING_DEVICE	99999	/* TBD */
#define TYPEID_MOON	14
#define TYPEID_LARGE_ASSEMBLY_ARRAY 29613
#define TYPEID_XLARGE_ASSEMBLY_ARRAY 24656

/* Same group and type for secure cargo containers as well */
#define GROUPID_CORPORATE_HANGAR_ARRAY 471
#define GROUPID_CARGO_CONTAINER 12
#define TYPEID_CARGO_CONTAINER 23
#define TYPEID_CORPORATE_HANGAR_ARRAY 17621
#define GROUPID_SPAWN_CONTAINER 306
#define GROUPID_SECURE_CONTAINER 340
#define GROUPID_DAMAGE_CONTROL 60
#define GROUPID_WRECK 186
#define GROUPID_STASIS_WEB 65
#define GROUPID_DATA_MINER 538
#define GROUPID_TRACTOR_BEAM 650
#define TYPEID_SALVAGER 25861
#define GROUPID_SALVAGER 1122

#define WARP_RANGE 150000
#define WARP_RANGE_MOON   10000000
#define WARP_RANGE_PLANET 55000000

#define DOCKING_RANGE 200
#define LOOT_RANGE 2490
#define JUMP_RANGE 2350
#define CORP_HANGAR_LOOT_RANGE 3000
#define SCANNER_RANGE 2147483647000

#define TYPEID_GLACIAL_MASS 16263

#define CONFIG_MAX_SLOWBOAT_RANGE 15000
#define CONFIG_OVERVIEW_RANGE 300000

;System (ID: 0)          Owner (ID: 1)           Celestial (ID: 2)           Station (ID: 3)
;Material (ID: 4)        Accessories (ID: 5)     Ship (ID: 6)                Module (ID: 7)
;Charge (ID: 8)          Blueprint (ID: 9)       Trading (ID: 10)            Entity (ID: 11)
;Bonus (ID: 14)          Skill (ID: 16)          Commodity (ID: 17)          Drone (ID: 18)
;Implant (ID: 20)        Deployable (ID: 22)     Structure (ID: 23)          Reaction (ID: 24)
;Asteroid (ID: 25)

; Mission Warp Gate IDs
;${Entity[Acceleration Gate].Category} = Celestial
;${Entity[Acceleration Gate].CategoryID} = 2
;${Entity[Acceleration Gate].Type} = Acceleration Gate
;${Entity[Acceleration Gate].TypeID} = 17831
;${Entity[Acceleration Gate].Group} = Warp Gate
;${Entity[Acceleration Gate].GroupID} = 366

#define CATEGORYID_CELESTIAL	2
#define CATEGORYID_STATION 		3
#define CATEGORYID_MINERAL 		4
#define CATEGORYID_SHIP    		6
#define CATEGORYID_CHARGE  		8
#define CATEGORYID_ENTITY		11
#define CATEGORYID_ORE     		25
#define CATEGORYID_GLACIAL_MASS 25

#define CATEGORYID_STRUCTURE	23
#define GROUPID_CONTROL_TOWER   365

/* for obj_Sound.iss */
#define ALARMSOUND	"${Script.CurrentDirectory}/sounds/alarm.wav"
#define DETECTSOUND	"${Script.CurrentDirectory}/sounds/detect.wav"
#define TELLSOUND	"${Script.CurrentDirectory}/sounds/tell.wav"
#define LEVELSOUND	"${Script.CurrentDirectory}/sounds/level.wav"
#define WARNSOUND	"${Script.CurrentDirectory}/sounds/warning.wav"


#define GROUP_GANGLINK 316
#define GROUP_ACCELERATIONGATEKEYS 474
#define GROUP_AGENTSINSPACE 517
#define GROUP_ALLIANCE 32
#define GROUP_AMMO 83
#define GROUP_ARKONOR 450
#define GROUP_ASSEMBLYARRAY 397
#define GROUP_ASTEROIDANGELCARTELBATTLECRUISER 576
#define GROUP_ASTEROIDANGELCARTELBATTLESHIP 552
#define GROUP_ASTEROIDANGELCARTELCOMMANDERBATTLECRUISER 793
#define GROUP_ASTEROIDANGELCARTELCOMMANDERCRUISER 790
#define GROUP_ASTEROIDANGELCARTELCOMMANDERDESTROYER 794
#define GROUP_ASTEROIDANGELCARTELCOMMANDERFRIGATE 789
#define GROUP_ASTEROIDANGELCARTELCRUISER 551
#define GROUP_ASTEROIDANGELCARTELDESTROYER 575
#define GROUP_ASTEROIDANGELCARTELFRIGATE 550
#define GROUP_ASTEROIDANGELCARTELHAULER 554
#define GROUP_ASTEROIDANGELCARTELOFFICER 553
#define GROUP_ASTEROIDBELT 9
#define GROUP_ASTEROIDBLOODRAIDERSBATTLECRUISER 578
#define GROUP_ASTEROIDBLOODRAIDERSBATTLESHIP 556
#define GROUP_ASTEROIDBLOODRAIDERSCOMMANDERBATTLECRUISER 795
#define GROUP_ASTEROIDBLOODRAIDERSCOMMANDERCRUISER 791
#define GROUP_ASTEROIDBLOODRAIDERSCOMMANDERDESTROYER 796
#define GROUP_ASTEROIDBLOODRAIDERSCOMMANDERFRIGATE 792
#define GROUP_ASTEROIDBLOODRAIDERSCRUISER 555
#define GROUP_ASTEROIDBLOODRAIDERSDESTROYER 577
#define GROUP_ASTEROIDBLOODRAIDERSFRIGATE 557
#define GROUP_ASTEROIDBLOODRAIDERSHAULER 558
#define GROUP_ASTEROIDBLOODRAIDERSOFFICER 559
#define GROUP_ASTEROIDGURISTASBATTLECRUISER 580
#define GROUP_ASTEROIDGURISTASBATTLESHIP 560
#define GROUP_ASTEROIDGURISTASCOMMANDERBATTLECRUISER 797
#define GROUP_ASTEROIDGURISTASCOMMANDERCRUISER 798
#define GROUP_ASTEROIDGURISTASCOMMANDERDESTROYER 799
#define GROUP_ASTEROIDGURISTASCOMMANDERFRIGATE 800
#define GROUP_ASTEROIDGURISTASCRUISER 561
#define GROUP_ASTEROIDGURISTASDESTROYER 579
#define GROUP_ASTEROIDGURISTASFRIGATE 562
#define GROUP_ASTEROIDGURISTASHAULER 563
#define GROUP_ASTEROIDGURISTASOFFICER 564
#define GROUP_ASTEROIDROGUEDRONEBATTLECRUISER 755
#define GROUP_ASTEROIDROGUEDRONEBATTLESHIP 756
#define GROUP_ASTEROIDROGUEDRONECRUISER 757
#define GROUP_ASTEROIDROGUEDRONEDESTROYER 758
#define GROUP_ASTEROIDROGUEDRONEFRIGATE 759
#define GROUP_ASTEROIDROGUEDRONEHAULER 760
#define GROUP_ASTEROIDROGUEDRONESWARM 761
#define GROUP_ASTEROIDSANSHASNATIONBATTLECRUISER 582
#define GROUP_ASTEROIDSANSHASNATIONBATTLESHIP 565
#define GROUP_ASTEROIDSANSHASNATIONCOMMANDERBATTLECRUISER 807
#define GROUP_ASTEROIDSANSHASNATIONCOMMANDERCRUISER 808
#define GROUP_ASTEROIDSANSHASNATIONCOMMANDERDESTROYER 809
#define GROUP_ASTEROIDSANSHASNATIONCOMMANDERFRIGATE 810
#define GROUP_ASTEROIDSANSHASNATIONCRUISER 566
#define GROUP_ASTEROIDSANSHASNATIONDESTROYER 581
#define GROUP_ASTEROIDSANSHASNATIONFRIGATE 567
#define GROUP_ASTEROIDSANSHASNATIONHAULER 568
#define GROUP_ASTEROIDSANSHASNATIONOFFICER 569
#define GROUP_ASTEROIDSERPENTISBATTLECRUISER 584
#define GROUP_ASTEROIDSERPENTISBATTLESHIP 570
#define GROUP_ASTEROIDSERPENTISCOMMANDERBATTLECRUISER 811
#define GROUP_ASTEROIDSERPENTISCOMMANDERCRUISER 812
#define GROUP_ASTEROIDSERPENTISCOMMANDERDESTROYER 813
#define GROUP_ASTEROIDSERPENTISCOMMANDERFRIGATE 814
#define GROUP_ASTEROIDSERPENTISCRUISER 571
#define GROUP_ASTEROIDSERPENTISDESTROYER 583
#define GROUP_ASTEROIDSERPENTISFRIGATE 572
#define GROUP_ASTEROIDSERPENTISHAULER 573
#define GROUP_ASTEROIDSERPENTISOFFICER 574
#define GROUP_ASTEROIDROGUEDRONECOMMANDERFRIGATE 847
#define GROUP_ASTEROIDROGUEDRONECOMMANDERDESTROYER 846
#define GROUP_ASTEROIDROGUEDRONECOMMANDERCRUISER 845
#define GROUP_ASTEROIDROGUEDRONECOMMANDERBATTLECRUISER 843
#define GROUP_ASTEROIDROGUEDRONECOMMANDERBATTLESHIP 844
#define GROUP_ASTEROIDANGELCARTELCOMMANDERBATTLESHIP 848
#define GROUP_ASTEROIDBLOODRAIDERSCOMMANDERBATTLESHIP 849
#define GROUP_ASTEROIDGURISTASCOMMANDERBATTLESHIP 850
#define GROUP_ASTEROIDSANSHASNATIONCOMMANDERBATTLESHIP 851
#define GROUP_ASTEROIDSERPENTISCOMMANDERBATTLESHIP 852
#define GROUP_MISSIONAMARREMPIRECARRIER 865
#define GROUP_MISSIONCALDARISTATECARRIER 866
#define GROUP_MISSIONGALLENTEFEDERATIONCARRIER 867
#define GROUP_MISSIONMINMATARREPUBLICCARRIER 868
#define GROUP_MISSIONFIGHTERDRONE 861
#define GROUP_MISSIONGENERICFREIGHTERS 875
#define GROUP_ASSAULTSHIP 324
#define GROUP_AUDITLOGSECURECONTAINER 448
#define GROUP_BATTLECRUISER 419
#define GROUP_BATTLESHIP 27
#define GROUP_BEACON 310
#define GROUP_BILLBOARD 323
#define GROUP_BIOHAZARD 284
#define GROUP_BIOMASS 14
#define GROUP_BISTOT 451
#define GROUP_BLACKOPS 898
#define GROUP_BOMB 90
#define GROUP_BOMBECM 863
#define GROUP_BOMBENERGY 864
#define GROUP_BOOSTER 303
#define GROUP_BUBBLEPROBELAUNCHER 589
#define GROUP_CAPDRAINDRONE 544
#define GROUP_CAPACITORBOOSTER 76
#define GROUP_CAPACITORBOOSTERCHARGE 87
#define GROUP_CAPITALINDUSTRIALSHIP 883
#define GROUP_CAPSULE 29
#define GROUP_CARGOCONTAINER 12
#define GROUP_CARRIER 547
#define GROUP_CHARACTER 1
#define GROUP_CHEATMODULEGROUP 225
#define GROUP_CLOAKINGDEVICE 330
#define GROUP_CLONE 23
#define GROUP_CLOUD 227
#define GROUP_COMBATDRONE 100
#define GROUP_COMET 305
#define GROUP_COMMANDSHIP 540
#define GROUP_COMPOSITE 429
#define GROUP_COMPUTERINTERFACENODE 317
#define GROUP_CONCORDDRONE 301
#define GROUP_CONSTELLATION 4
#define GROUP_CONSTRUCTIONPLATFORM 307
#define GROUP_CONTROLTOWER 365
#define GROUP_CONVOY 297
#define GROUP_CONVOYDRONE 298
#define GROUP_CORPORATEHANGARARRAY 471
#define GROUP_CORPORATION 2
#define GROUP_COSMICANOMALY 885
#define GROUP_COSMICSIGNATURE 502
#define GROUP_COVERTOPS 830
#define GROUP_CROKITE 452
#define GROUP_CRUISER 26
#define GROUP_CUSTOMSOFFICIAL 446
#define GROUP_CYNOSURALGENERATORARRAY 838
#define GROUP_CYNOSURALGENERATORARRAY 838
#define GROUP_CYNOSURALSYSTEMJAMMER 839
#define GROUP_CYNOSURALSYSTEMJAMMER 839
#define GROUP_DARKOCHRE 453
#define GROUP_DATAINTERFACES 716
#define GROUP_DATACORES 333
#define GROUP_DEADSPACEANGELCARTELBATTLECRUISER 593
#define GROUP_DEADSPACEANGELCARTELBATTLESHIP 594
#define GROUP_DEADSPACEANGELCARTELCRUISER 595
#define GROUP_DEADSPACEANGELCARTELDESTROYER 596
#define GROUP_DEADSPACEANGELCARTELFRIGATE 597
#define GROUP_DEADSPACEBLOODRAIDERSBATTLECRUISER 602
#define GROUP_DEADSPACEBLOODRAIDERSBATTLESHIP 603
#define GROUP_DEADSPACEBLOODRAIDERSCRUISER 604
#define GROUP_DEADSPACEBLOODRAIDERSDESTROYER 605
#define GROUP_DEADSPACEBLOODRAIDERSFRIGATE 606
#define GROUP_DEADSPACEGURISTASBATTLECRUISER 611
#define GROUP_DEADSPACEGURISTASBATTLESHIP 612
#define GROUP_DEADSPACEGURISTASCRUISER 613
#define GROUP_DEADSPACEGURISTASDESTROYER 614
#define GROUP_DEADSPACEGURISTASFRIGATE 615
#define GROUP_DEADSPACEOVERSEER 435
#define GROUP_DEADSPACEOVERSEERSBELONGINGS 496
#define GROUP_DEADSPACEOVERSEERSSENTRY 495
#define GROUP_DEADSPACEOVERSEERSSTRUCTURE 494
#define GROUP_DEADSPACEROGUEDRONEBATTLECRUISER 801
#define GROUP_DEADSPACEROGUEDRONEBATTLESHIP 802
#define GROUP_DEADSPACEROGUEDRONECRUISER 803
#define GROUP_DEADSPACEROGUEDRONEDESTROYER 804
#define GROUP_DEADSPACEROGUEDRONEFRIGATE 805
#define GROUP_DEADSPACEROGUEDRONESWARM 806
#define GROUP_DEADSPACESANSHASNATIONBATTLECRUISER 620
#define GROUP_DEADSPACESANSHASNATIONBATTLESHIP 621
#define GROUP_DEADSPACESANSHASNATIONCRUISER 622
#define GROUP_DEADSPACESANSHASNATIONDESTROYER 623
#define GROUP_DEADSPACESANSHASNATIONFRIGATE 624
#define GROUP_DEADSPACESERPENTISBATTLECRUISER 629
#define GROUP_DEADSPACESERPENTISBATTLESHIP 630
#define GROUP_DEADSPACESERPENTISCRUISER 631
#define GROUP_DEADSPACESERPENTISDESTROYER 632
#define GROUP_DEADSPACESERPENTISFRIGATE 633
#define GROUP_DEFENDERMISSILE 88
#define GROUP_DESTROYER 420
#define GROUP_DESTRUCTIBLEAGENTSINSPACE 715
#define GROUP_DESTRUCTIBLESENTRYGUN 383
#define GROUP_DESTRUCTIBLESTATIONSERVICES 874
#define GROUP_DREADNOUGHT 485
#define GROUP_ECCM 202
#define GROUP_ELECTRONICWARFAREBATTERY 439
#define GROUP_ELECTRONICWARFAREDRONE 639
#define GROUP_ELITEBATTLESHIP 381
#define GROUP_ENERGYNEUTRALIZINGBATTERY 837
#define GROUP_ENERGYWEAPON 53
#define GROUP_EXHUMER 543
#define GROUP_FACTION 19
#define GROUP_FACTIONDRONE 288
#define GROUP_FAKESKILLS 505
#define GROUP_FIGHTERDRONE 549
#define GROUP_FORCEFIELD 411
#define GROUP_FORCEFIELDARRAY 445
#define GROUP_FREIGHTCONTAINER 649
#define GROUP_FREIGHTER 513
#define GROUP_FREQUENCYCRYSTAL 86
#define GROUP_FREQUENCYMININGLASER 483
#define GROUP_FRIGATE 25
#define GROUP_FROZEN 281
#define GROUP_GASCLOUDHARVESTER 737
#define GROUP_GASISOTOPES 422
#define GROUP_GLOBALWARPDISRUPTOR 368
#define GROUP_GNEISS 467
#define GROUP_HARVESTABLECLOUD 711
#define GROUP_HEAVYASSAULTSHIP 358
#define GROUP_HEDBERGITE 454
#define GROUP_HEMORPHITE 455
#define GROUP_HYBRIDAMMO 85
#define GROUP_HYBRIDWEAPON 74
#define GROUP_ICE 465
#define GROUP_ICEPRODUCT 423
#define GROUP_INDUSTRIAL 28
#define GROUP_INTERCEPTOR 831
#define GROUP_INTERDICTOR 541
#define GROUP_INTERMEDIATEMATERIALS 428
#define GROUP_JASPET 456
#define GROUP_JUMPPORTALARRAY 707
#define GROUP_JUMPPORTALGENERATOR 590
#define GROUP_KERNITE 457
#define GROUP_LCODRONE 279
#define GROUP_LANDMARK 318
#define GROUP_LARGECOLLIDABLEOBJECT 226
#define GROUP_LARGECOLLIDABLESHIP 784
#define GROUP_LARGECOLLIDABLESTRUCTURE 319
#define GROUP_LEARNING 267
#define GROUP_LEASE 652
#define GROUP_LIVESTOCK 283
#define GROUP_LOGISTICDRONE 640
#define GROUP_LOGISTICS 832
#define GROUP_LOGISTICSARRAY 710
#define GROUP_MERCOXIT 468
#define GROUP_MINE 92
#define GROUP_MINERAL 18
#define GROUP_MININGBARGE 463
#define GROUP_MININGDRONE 101
#define GROUP_MININGLASER 54
#define GROUP_MISSILE 84
#define GROUP_MISSILELAUNCHER 56
#define GROUP_MISSILELAUNCHERASSAULT 511
#define GROUP_MISSILELAUNCHERBOMB 862
#define GROUP_MISSILELAUNCHERCITADEL 524
#define GROUP_MISSILELAUNCHERCRUISE 506
#define GROUP_MISSILELAUNCHERDEFENDER 512
#define GROUP_MISSILELAUNCHERHEAVY 510
#define GROUP_MISSILELAUNCHERHEAVYASSAULT 771
#define GROUP_MISSILELAUNCHERROCKET 507
#define GROUP_MISSILELAUNCHERSIEGE 508
#define GROUP_MISSILELAUNCHERSNOWBALL 501
#define GROUP_MISSILELAUNCHERSTANDARD 509
#define GROUP_MISSIONAMARREMPIREBATTLECRUISER 666
#define GROUP_MISSIONAMARREMPIREBATTLESHIP 667
#define GROUP_MISSIONAMARREMPIRECRUISER 668
#define GROUP_MISSIONAMARREMPIREDESTROYER 669
#define GROUP_MISSIONAMARREMPIREFRIGATE 665
#define GROUP_MISSIONAMARREMPIREOTHER 670
#define GROUP_MISSIONCONCORDBATTLECRUISER 696
#define GROUP_MISSIONCONCORDBATTLESHIP 697
#define GROUP_MISSIONCONCORDCRUISER 695
#define GROUP_MISSIONCONCORDDESTROYER 694
#define GROUP_MISSIONCONCORDFRIGATE 693
#define GROUP_MISSIONCONCORDOTHER 698
#define GROUP_MISSIONCALDARISTATEBATTLECRUISER 672
#define GROUP_MISSIONCALDARISTATEBATTLESHIP 674
#define GROUP_MISSIONCALDARISTATECRUISER 673
#define GROUP_MISSIONCALDARISTATEDESTROYER 676
#define GROUP_MISSIONCALDARISTATEFRIGATE 671
#define GROUP_MISSIONCALDARISTATEOTHER 675
#define GROUP_MISSIONDRONE 337
#define GROUP_MISSIONGALLENTEFEDERATIONBATTLECRUISER 681
#define GROUP_MISSIONGALLENTEFEDERATIONBATTLESHIP 680
#define GROUP_MISSIONGALLENTEFEDERATIONCRUISER 678
#define GROUP_MISSIONGALLENTEFEDERATIONDESTROYER 679
#define GROUP_MISSIONGALLENTEFEDERATIONFRIGATE 677
#define GROUP_MISSIONGALLENTEFEDERATIONOTHER 682
#define GROUP_MISSIONKHANIDBATTLECRUISER 690
#define GROUP_MISSIONKHANIDBATTLESHIP 691
#define GROUP_MISSIONKHANIDCRUISER 689
#define GROUP_MISSIONKHANIDDESTROYER 688
#define GROUP_MISSIONKHANIDFRIGATE 687
#define GROUP_MISSIONKHANIDOTHER 692
#define GROUP_MISSIONMINMATARREPUBLICBATTLECRUISER 685
#define GROUP_MISSIONMINMATARREPUBLICBATTLESHIP 706
#define GROUP_MISSIONMINMATARREPUBLICCRUISER 705
#define GROUP_MISSIONMINMATARREPUBLICDESTROYER 684
#define GROUP_MISSIONMINMATARREPUBLICFRIGATE 683
#define GROUP_MISSIONMINMATARREPUBLICOTHER 686
#define GROUP_MISSIONMORDUBATTLECRUISER 702
#define GROUP_MISSIONMORDUBATTLESHIP 703
#define GROUP_MISSIONMORDUCRUISER 701
#define GROUP_MISSIONMORDUDESTROYER 700
#define GROUP_MISSIONMORDUFRIGATE 699
#define GROUP_MISSIONMORDUOTHER 704
#define GROUP_MOBILEHYBRIDSENTRY 449
#define GROUP_MOBILELABORATORY 413
#define GROUP_MOBILELASERSENTRY 430
#define GROUP_MOBILEMISSILESENTRY 417
#define GROUP_TRANSPORTSHIP 380
#define GROUP_JUMPFREIGHTER 902
#define GROUP_MOBILEPOWERCORE 414
#define GROUP_MOBILEPROJECTILESENTRY 426
#define GROUP_MOBILEREACTOR 438
#define GROUP_MOBILESENTRYGUN 336
#define GROUP_MOBILESHIELDGENERATOR 418
#define GROUP_MOBILESTORAGE 364
#define GROUP_MOBILEWARPDISRUPTOR 361
#define GROUP_MONEY 17
#define GROUP_MOON 8
#define GROUP_MOONMATERIALS 427
#define GROUP_MOONMINING 416
#define GROUP_MOTHERSHIP 659
#define GROUP_OMBER 469
#define GROUP_OVERSEERPERSONALEFFECTS 493
#define GROUP_OUTPOSTIMPROVEMENTS 872
#define GROUP_OUTPOSTUPGRADES 876
#define GROUP_PIRATEDRONE 185
#define GROUP_PLAGIOCLASE 458
#define GROUP_PLANET 7
#define GROUP_PLANETARYCLOUD 312
#define GROUP_POLICEDRONE 182
#define GROUP_PROJECTILEWEAPON 55
#define GROUP_PROTECTIVESENTRYGUN 180
#define GROUP_PROXIMITYDRONE 97
#define GROUP_PYROXERES 459
#define GROUP_RADIOACTIVE 282
#define GROUP_FORCERECONSHIP 833
#define GROUP_COMBATRECONSHIP 906
#define GROUP_REFINABLES 355
#define GROUP_REFININGARRAY 311
#define GROUP_REGION 3
#define GROUP_REMOTESENSORBOOSTER 290
#define GROUP_REMOTESENSORDAMPER 208
#define GROUP_REPAIRDRONE 299
#define GROUP_RING 13
#define GROUP_ROGUEDRONE 287
#define GROUP_ROOKIESHIP 237
#define GROUP_SCANPROBELAUNCHER 481
#define GROUP_SCANNERARRAY 709
#define GROUP_SCANNERPROBE 479
#define GROUP_SCORDITE 460
#define GROUP_SECURECARGOCONTAINER 340
#define GROUP_SENSORBOOSTER 212
#define GROUP_SENSORDAMPENINGBATTERY 440
#define GROUP_SENTRYGUN 99
#define GROUP_SHIELDBOOSTER 40
#define GROUP_SHIELDHARDENINGARRAY 444
#define GROUP_SHIPMAINTENANCEARRAY 363
#define GROUP_SHUTTLE 31
#define GROUP_SIEGEMODULE 515
#define GROUP_SILO 404
#define GROUP_SOLARSYSTEM 5
#define GROUP_SPAWNCONTAINER 306
#define GROUP_SPODUMAIN 461
#define GROUP_STARGATE 10
#define GROUP_STASISWEBIFICATIONBATTERY 441
#define GROUP_STASISWEBIFYINGDRONE 641
#define GROUP_STATION 15
#define GROUP_STATIONSERVICES 16
#define GROUP_STATIONUPGRADEPLATFORM 835
#define GROUP_STATIONIMPROVEMENTPLATFORM 836
#define GROUP_STEALTHBOMBER 834
#define GROUP_STEALTHEMITTERARRAY 480
#define GROUP_STORYLINEBATTLESHIP 523
#define GROUP_STORYLINECRUISER 522
#define GROUP_STORYLINEFRIGATE 520
#define GROUP_STORYLINEMISSIONBATTLESHIP 534
#define GROUP_STORYLINEMISSIONCRUISER 533
#define GROUP_STORYLINEMISSIONFRIGATE 527
#define GROUP_STRIPMINER 464
#define GROUP_SUN 6
#define GROUP_SUPERWEAPON 588
#define GROUP_SURVEYPROBE 492
#define GROUP_SYSTEM 0
#define GROUP_TEMPORARYCLOUD 335
#define GROUP_TITAN 30
#define GROUP_TOOL 332
#define GROUP_TRACKINGARRAY 473
#define GROUP_TRACKINGCOMPUTER 213
#define GROUP_TRACKINGDISRUPTOR 291
#define GROUP_TRACKINGLINK 209
#define GROUP_TRADESESSION 95
#define GROUP_TRADING 94
#define GROUP_TUTORIALDRONE 286
#define GROUP_UNANCHORINGDRONE 470
#define GROUP_VELDSPAR 462
#define GROUP_VOUCHER 24
#define GROUP_WARPDISRUPTFIELDGENERATOR 899
#define GROUP_WARPDISRUPTIONPROBE 548
#define GROUP_WARPGATE 366
#define GROUP_WARPSCRAMBLINGBATTERY 443
#define GROUP_WARPSCRAMBLINGDRONE 545
#define GROUP_WRECK 186
#define GROUP_MISSIONGENERICBATTLESHIPS 816
#define GROUP_MISSIONGENERICCRUISERS 817
#define GROUP_MISSIONGENERICFRIGATES 818
#define GROUP_MISSIONTHUKKERBATTLECRUISER 822
#define GROUP_MISSIONTHUKKERBATTLESHIP 823
#define GROUP_MISSIONTHUKKERCRUISER 824
#define GROUP_MISSIONTHUKKERDESTROYER 825
#define GROUP_MISSIONTHUKKERFRIGATE 826
#define GROUP_MISSIONTHUKKEROTHER 827
#define GROUP_MISSIONGENERICBATTLECRUISERS 828
#define GROUP_MISSIONGENERICDESTROYERS 829
#define GROUP_DEADSPACEOVERSEERFRIGATE 819
#define GROUP_DEADSPACEOVERSEERCRUISER 820
#define GROUP_DEADSPACEOVERSEERBATTLESHIP 821
#define GROUP_ELECTRONICATTACKSHIPS 893
#define GROUP_HEAVYINTERDICTORS 894
#define GROUP_MARAUDERS 900
#define GROUP_TARGETPAINTER 379

#define TYPE_ACCELERATION_GATE 17831

#define TYPE_PUNISHER 597
#define TYPE_DRAKE    24698
#define TYPE_HAWK     11379
#define TYPE_KESTREL  602
#define TYPE_RIFTER   587
#define TYPE_RAVEN    638

/* Drone type defines */
/* Combat */
#define GROUP_DRONE_FIGHTERBOMBER 1023
#define GROUP_DRONE_FIGHTER 549
#define GROUP_DRONE_ATTACKSCOUT 100

/* Subtypes */
/* Heavy drones */
#define TYPEID_DRONE_HEAVY_BERSERKER_I	 2476
#define TYPEID_DRONE_HEAVY_BERSERKER_II	 2478
#define TYPEID_DRONE_HEAVY_INTEGRATED_BERSERKER	 28266
#define TYPEID_DRONE_HEAVY_AUGMENTED_BERSERKER	 28268
#define TYPEID_DRONE_HEAVY_REP_FLT_BERSERKER	 31892
#define TYPEID_DRONE_HEAVY_OGRE_I	 2444
#define TYPEID_DRONE_HEAVY_OGRE_II	 2446
#define TYPEID_DRONE_HEAVY_INTEGRATED_OGRE	 28286
#define TYPEID_DRONE_HEAVY_AUGMENTED_OGRE	 28288
#define TYPEID_DRONE_HEAVY_FED_NAVY_OGRE	 31884
#define TYPEID_DRONE_HEAVY_PRAETOR_I	 2193
#define TYPEID_DRONE_HEAVY_PRAETOR_II	 2195
#define TYPEID_DRONE_HEAVY_INTEGRATED_PRAETOR	 28290
#define TYPEID_DRONE_HEAVY_AUGMENTED_PRAETOR	 28292
#define TYPEID_DRONE_HEAVY_IMP_NAVY_PRAETOR	 31870
#define TYPEID_DRONE_HEAVY_WASP_I	 1201
#define TYPEID_DRONE_HEAVY_WASP_II	 2436
#define TYPEID_DRONE_HEAVY_INTEGRATED_WASP	 28306
#define TYPEID_DRONE_HEAVY_AUGMENTED_WASP	 28308
#define TYPEID_DRONE_HEAVY_CAL_NAVY_WASP	 31876

/* Medium drones */
#define TYPEID_DRONE_MEDIUM_HAMMERHEAD_I	 2183
#define TYPEID_DRONE_MEDIUM_HAMMERHEAD_II	 2185
#define TYPEID_DRONE_MEDIUM_INTEGRATED_HAMMERHEAD	 28270
#define TYPEID_DRONE_MEDIUM_AUGMENTED_HAMMERHEAD	 28272
#define TYPEID_DRONE_MEDIUM_FED_NAVY_HAMMERHEAD	 31882
#define TYPEID_DRONE_MEDIUM_INFILTRATOR_I	 2173
#define TYPEID_DRONE_MEDIUM_INFILTRATOR_II	 2175
#define TYPEID_DRONE_MEDIUM_INTEGRATED_INFILTRATOR	 28282
#define TYPEID_DRONE_MEDIUM_AUGMENTED_INFILTRATOR	 28284
#define TYPEID_DRONE_MEDIUM_IMP_NAVY_INFILTRATOR	 31866
#define TYPEID_DRONE_MEDIUM_VALKYRIE_I	 15510
#define TYPEID_DRONE_MEDIUM_VALKYRIE_II	 21640
#define TYPEID_DRONE_MEDIUM_INTEGRATED_VALKYRIE	 28294
#define TYPEID_DRONE_MEDIUM_AUGMENTED_VALKYRIE	 28296
#define TYPEID_DRONE_MEDIUM_REP_FLT_VALKYRIE	 31890
#define TYPEID_DRONE_MEDIUM_VESPA_I	 15508
#define TYPEID_DRONE_MEDIUM_VESPA_II	 21638
#define TYPEID_DRONE_MEDIUM_INTEGRATED_VESPA	 28298
#define TYPEID_DRONE_MEDIUM_AUGMENTED_VESPA	 28300
#define TYPEID_DRONE_MEDIUM_CAL_NAVY_VESPA	 31874

/* Light drones */
#define TYPEID_DRONE_LIGHT_ACOLYTE_I	 2203
#define TYPEID_DRONE_LIGHT_ACOLYTE_II	 2205
#define TYPEID_DRONE_LIGHT_INTEGRATED_ACOLYTE	 28262
#define TYPEID_DRONE_LIGHT_AUGMENTED_ACOLYTE	 28264
#define TYPEID_DRONE_LIGHT_IMP_NAVY_ACOLYTE	 31864
#define TYPEID_DRONE_LIGHT_HOBGOBLIN_I	 2454
#define TYPEID_DRONE_LIGHT_HOBGOBLIN_II	 2456
#define TYPEID_DRONE_LIGHT_INTEGRATED_HOBGOBLIN	 28274
#define TYPEID_DRONE_LIGHT_AUGMENTED_HOBGOBLIN	 28276
#define TYPEID_DRONE_LIGHT_FED_NAVY_HOBGOBLIN	 31880
#define TYPEID_DRONE_LIGHT_HORNET_I	 2464
#define TYPEID_DRONE_LIGHT_HORNET_II	 2466
#define TYPEID_DRONE_LIGHT_INTEGRATED_HORNET	 28278
#define TYPEID_DRONE_LIGHT_AUGMENTED_HORNET	 28280
#define TYPEID_DRONE_LIGHT_CAL_NAVY_HORNET	 31872
#define TYPEID_DRONE_LIGHT_WARRIOR_I	 2486
#define TYPEID_DRONE_LIGHT_WARRIOR_II	 2488
#define TYPEID_DRONE_LIGHT_INTEGRATED_WARRIOR	 28302
#define TYPEID_DRONE_LIGHT_AUGMENTED_WARRIOR	 28304
#define TYPEID_DRONE_LIGHT_REP_FLT_WARRIOR	 31888

; Sentry drones
#define TYPEID_DRONE_SENTRY_BOUNCER_I	 23563
#define TYPEID_DRONE_SENTRY_BOUNCER_II	 28215
#define TYPEID_DRONE_SENTRY_REP_FLT_BOUNCER	 31894
#define TYPEID_DRONE_SENTRY_CURATOR_I	 23525
#define TYPEID_DRONE_SENTRY_CURATOR_II	 28213
#define TYPEID_DRONE_SENTRY_IMP_NAVY_CURATOR	 31868
#define TYPEID_DRONE_SENTRY_GARDE_I	 23561
#define TYPEID_DRONE_SENTRY_GARDE_II	 28211
#define TYPEID_DRONE_SENTRY_FED_NAVY_GARDE	 31886
#define TYPEID_DRONE_SENTRY_WARDEN_I	 23559
#define TYPEID_DRONE_SENTRY_WARDEN_II	 28209
#define TYPEID_DRONE_SENTRY_CAL_NAVY_WARDEN	 31878

/* Combat utility */
#define GROUP_DRONE_UTILITYENERGY 544
#define GROUP_DRONE_UTILITYWEBBER 641

/* Logistic Drones */
#define GROUP_DRONE_LOGISTICS 640

/* Mining Drones */
#define GROUP_DRONE_MINING 101