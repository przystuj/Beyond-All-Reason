return {
	armshock = {
		acceleration = 0.023,
		brakerate = 0.3,
		buildcostenergy = 65687,
		buildcostmetal = 3120,
		buildpic = "ARMSHOCK.DDS",
		buildtime = 101218,
		canmove = true,
		category = "ALL NOTSUB WEAPON NOTAIR NOTHOVER SURFACE",
		collisionvolumeoffsets = "0 -1 1",
		collisionvolumescales = "57 54 57",
		collisionvolumetest = 1,
		collisionvolumetype = "CylY",
		corpse = "DEAD",
		description = "All-Terrain Heavy Plasma Cannon",
		explodeas = "SHOCKER",
		footprintx = 4,
		footprintz = 4,
		hightrajectory = 2,
		idleautoheal = 5,
		idletime = 1800,
		mass = 200000,
		maxdamage = 9000,
		maxslope = 17,
		maxvelocity = 1.1,
		maxwaterdepth = 0,
		movementclass = "HTKBOT4",
		name = "Vanguard",
		nochasecategory = "VTOL",
		objectname = "ARMSHOCK",
		seismicsignature = 0,
		selfdestructas = "SHOCKER",
		sightdistance = 625,
		turninplaceanglelimit = 140,
		turninplacespeedlimit = 0.726,
		turnrate = 231,
		customparams = {},
		featuredefs = {
			dead = {
				blocking = true,
				category = "corpses",
				collisionvolumeoffsets = "-3.37104034424 -1.05229058838 1.8899307251",
				collisionvolumescales = "64.0154266357 41.4324188232 55.433883667",
				collisionvolumetype = "Box",
				damage = 3000,
				description = "Vanguard Wreckage",
				energy = 0,
				featuredead = "HEAP",
				featurereclamate = "SMUDGE01",
				footprintx = 3,
				footprintz = 3,
				height = 20,
				hitdensity = 100,
				metal = 2028,
				object = "ARMSHOCK_DEAD",
				reclaimable = true,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
			heap = {
				blocking = false,
				category = "heaps",
				damage = 3015,
				description = "Vanguard Heap",
				energy = 0,
				featurereclamate = "SMUDGE01",
				footprintx = 3,
				footprintz = 3,
				height = 4,
				hitdensity = 100,
				metal = 811,
				object = "4X4D",
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
				[1] = "kbarmmov",
			},
			select = {
				[1] = "kbarmsel",
			},
		},
		weapondefs = {
			shocker = {
				areaofeffect = 192,
				avoidfeature = false,
				avoidfriendly = false,
				collidefriendly = false,
				craterboost = 0,
				cratermult = 0,
				edgeeffectiveness = 0.5,
				explosiongenerator = "custom:FLASHSMALLBUILDING",
				gravityaffected = "true",
				heightboostfactor = 2.8,
				impulseboost = 0.5,
				impulsefactor = 0.5,
				name = "ShockerHeavyCannon",
				noselfdamage = true,
				predictboost = 0.25,
				range = 1325,
				reloadtime = 8,
				size = 5,
				soundhit = "xplomed2",
				soundstart = "cannhvy5",
				targetborder = 1,
				turret = true,
				weapontype = "Cannon",
				weaponvelocity = 500,
				damage = {
					default = 1100,
					subs = 5,
				},
			},
		},
		weapons = {
			[1] = {
				badtargetcategory = "VTOL GROUNDSCOUT",
				def = "SHOCKER",
				onlytargetcategory = "SURFACE",
			},
		},
	},
}
