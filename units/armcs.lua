return {
	armcs = {
		acceleration = 0.1,
		brakerate = 0.3,
		buildcostenergy = 2130,
		buildcostmetal = 255,
		builddistance = 200,
		builder = true,
		buildpic = "ARMCS.DDS",
		buildtime = 7686,
		canmove = true,
		category = "ALL NOTLAND MOBILE NOTSUB NOWEAPON SHIP NOTAIR NOTHOVER SURFACE",
		collisionvolumeoffsets = "0 -5 -1",
		collisionvolumescales = "30 30 78",
		collisionvolumetest = 1,
		collisionvolumetype = "CylZ",
		corpse = "DEAD",
		description = "Tech Level 1",
		energymake = 15,
		energystorage = 15,
		explodeas = "BIG_UNITEX",
		floater = true,
		footprintx = 3,
		footprintz = 3,
		icontype = "sea",
		idleautoheal = 5,
		idletime = 1800,
		maxdamage = 1105,
		maxvelocity = 2.277,
		metalmake = 0.115,
		minwaterdepth = 15,
		movementclass = "BOAT4",
		name = "Construction Ship",
		objectname = "ARMCS",
		repairspeed = 125,
		seismicsignature = 0,
		selfdestructas = "BIG_UNIT",
		sightdistance = 291.20001,
		terraformspeed = 1250,
		turninplace = 0,
		turninplaceanglelimit = 140,
		turninplacespeedlimit = 1.50282,
		turnrate = 615,
		waterline = 4,
		windgenerator = 0.001,
		workertime = 250,
		buildoptions = {
			[1] = "armeyes",
			[2] = "armdl",
			[3] = "armdrag",
			[4] = "armclaw",
			[5] = "armtide",
			[6] = "armuwmex",
			[7] = "armfmkr",
			[8] = "armuwms",
			[9] = "armuwes",
			[10] = "armsy",
			[11] = "armasy",
			[12] = "armfhp",
			[13] = "asubpen",
			[14] = "armsonar",
			[15] = "armfrad",
			[16] = "armfdrag",
			[17] = "armtl",
			[18] = "armatl",
			[19] = "armfrt",
			[20] = "armfhlt",
			[21] = "armplat",
		},
		customparams = {},
		featuredefs = {
			dead = {
				blocking = false,
				category = "corpses",
				collisionvolumeoffsets = "0.322250366211 4.26757812502e-05 -0.458877563477",
				collisionvolumescales = "30.6897277832 28.4224853516 78.3307495117",
				collisionvolumetype = "Box",
				damage = 663,
				description = "Construction Ship Wreckage",
				energy = 0,
				featuredead = "HEAP",
				footprintx = 5,
				footprintz = 5,
				height = 4,
				hitdensity = 100,
				metal = 166,
				object = "ARMCS_DEAD",
				reclaimable = true,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
			heap = {
				blocking = false,
				category = "heaps",
				damage = 716,
				description = "Construction Ship Heap",
				energy = 0,
				footprintx = 2,
				footprintz = 2,
				height = 4,
				hitdensity = 100,
				metal = 59,
				object = "5X5A",
				reclaimable = true,
				resurrectable = 0,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
		},
		sounds = {
			build = "nanlath1",
			canceldestruct = "cancel2",
			repair = "repair1",
			underattack = "warning1",
			working = "reclaim1",
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
				[1] = "sharmmov",
			},
			select = {
				[1] = "sharmsel",
			},
		},
	},
}
