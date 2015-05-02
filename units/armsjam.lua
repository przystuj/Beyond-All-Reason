return {
	armsjam = {
		acceleration = 0.09,
		activatewhenbuilt = true,
		brakerate = 0.06,
		buildcostenergy = 1928,
		buildcostmetal = 131,
		buildpic = "ARMSJAM.DDS",
		buildtime = 6708,
		canmove = true,
		category = "ALL NOTLAND MOBILE NOTSUB NOWEAPON SHIP NOTAIR NOTHOVER SURFACE",
		collisionvolumeoffsets = "0 -2 0",
		collisionvolumescales = "22 22 64",
		collisionvolumetest = 1,
		collisionvolumetype = "CylZ",
		corpse = "DEAD",
		description = "Radar Jammer Ship",
		energymake = 18,
		energyuse = 18,
		explodeas = "SMALL_UNITEX",
		floater = true,
		footprintx = 3,
		footprintz = 3,
		icontype = "sea",
		idleautoheal = 5,
		idletime = 1800,
		maxdamage = 510,
		maxvelocity = 3.1,
		minwaterdepth = 6,
		movementclass = "BOAT4",
		name = "Escort",
		nochasecategory = "MOBILE",
		objectname = "ARMSJAM",
		onoffable = true,
		radardistancejam = 980,
		seismicsignature = 0,
		selfdestructas = "SMALL_UNIT",
		sightdistance = 390,
		turninplace = 0,
		turninplaceanglelimit = 140,
		turninplacespeedlimit = 2.046,
		turnrate = 540,
		waterline = 3,
		windgenerator = 0.001,
		customparams = {},
		featuredefs = {
			dead = {
				blocking = false,
				category = "corpses",
				collisionvolumeoffsets = "-0.304229736328 -7.05566407078e-07 -0.0",
				collisionvolumescales = "28.1084594727 19.4736785889 64.0",
				collisionvolumetype = "Box",
				damage = 306,
				description = "Escort Wreckage",
				energy = 0,
				featuredead = "HEAP",
				footprintx = 4,
				footprintz = 4,
				height = 40,
				hitdensity = 100,
				metal = 85,
				object = "ARMSJAM_DEAD",
				reclaimable = true,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
			heap = {
				blocking = false,
				category = "heaps",
				damage = 2016,
				description = "Escort Heap",
				energy = 0,
				footprintx = 2,
				footprintz = 2,
				height = 4,
				hitdensity = 100,
				metal = 23,
				object = "4X4A",
				reclaimable = true,
				resurrectable = 0,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
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
				[1] = "sharmmov",
			},
			select = {
				[1] = "radjam1",
			},
		},
		weapondefs = {
			bogus_ground_missile = {
				areaofeffect = 48,
				craterboost = 0,
				cratermult = 0,
				impulseboost = 0,
				impulsefactor = 0,
				metalpershot = 0,
				name = "Missiles",
				range = 800,
				reloadtime = 0.5,
				startvelocity = 450,
				tolerance = 9000,
				turnrate = 33000,
				turret = true,
				weaponacceleration = 101,
				weapontimer = 0.1,
				weapontype = "Cannon",
				weaponvelocity = 650,
				damage = {
					default = 0,
				},
			},
		},
		weapons = {
			[1] = {
				badtargetcategory = "MOBILE",
				def = "BOGUS_GROUND_MISSILE",
				onlytargetcategory = "NOTSUB",
			},
		},
	},
}
