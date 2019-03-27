return {
	armmark = {
		acceleration = 0.05175,
		activatewhenbuilt = true,
		brakerate = 0.0621,
		buildcostenergy = 1250,
		buildcostmetal = 100,
		buildpic = "ARMMARK.DDS",
		buildtime = 3800,
		canattack = false,
		canmove = true,
		category = "KBOT MOBILE ALL NOTSUB NOWEAPON NOTSHIP NOTAIR NOTHOVER SURFACE EMPABLE",
		collisionvolumeoffsets = "0 0 -1",
		collisionvolumescales = "26 24 16",
		collisionvolumetype = "box",
		corpse = "dead",
		description = "Radar Kbot",
		energymake = 8,
		energyuse = 20,
		explodeas = "smallexplosiongeneric",
		footprintx = 2,
		footprintz = 2,
		idleautoheal = 5,
		idletime = 1800,
		maxdamage = 320,
		maxslope = 16,
		maxvelocity = 1.35,
		maxwaterdepth = 0,
		movementclass = "KBOT3",
		name = "Marky",
		objectname = "Units/ARMMARK.s3o",
		onoffable = true,
		radardistance = 2200,
		script = "Units/ARMMARK.cob",
		selfdestructas = "smallExplosionGenericSelfd",
		sightdistance = 900,
		sonardistance = 0,
		turninplace = true,
		turninplaceanglelimit = 90,
		turninplacespeedlimit = 0.891,
		turnrate = 580.75,
		customparams = {
			model_author = "FireStorm",
			normalmaps = "yes",
			normaltex = "unittextures/Arm_normal.dds",
			subfolder = "armkbots/t2",
			techlevel = 2,
		},
		featuredefs = {
			dead = {
				blocking = true,
				category = "corpses",
				collisionvolumeoffsets = "-2.9700012207 0.0 2.42810058594",
				collisionvolumescales = "23.0599975586 13.375 26.6004943848",
				collisionvolumetype = "Box",
				damage = 280,
				description = "Marky Wreckage",
				featuredead = "HEAP",
				featurereclamate = "SMUDGE01",
				footprintx = 2,
				footprintz = 2,
				height = 20,
				hitdensity = 100,
				metal = 76,
				object = "Units/armmark_dead.s3o",
				reclaimable = true,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
			heap = {
				blocking = false,
				category = "heaps",
				collisionvolumescales = "35.0 4.0 6.0",
				collisionvolumetype = "cylY",
				damage = 256,
				description = "Marky Heap",
				featurereclamate = "SMUDGE01",
				footprintx = 2,
				footprintz = 2,
				height = 4,
				hitdensity = 100,
				metal = 38,
				object = "Units/arm2X2A.s3o",
				reclaimable = true,
				resurrectable = 0,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
		},
		sfxtypes = {
			pieceexplosiongenerators = {
				[1] = "deathceg2",
				[2] = "deathceg3",
				[3] = "deathceg4",
			},
		},
		sounds = {
			canceldestruct = "cancel2",
			underattack = "warning1",
			cant = {
				[1] = "cantdo4",
			},
			count = {
				[1] = "count6",
				[2] = "count5",
				[3] = "count4",
				[4] = "count3",
				[5] = "count2",
				[6] = "count1",
			},
			ok = {
				[1] = "kbarmmov",
			},
			select = {
				[1] = "akradsel",
			},
		},
	},
}
