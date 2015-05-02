return {
	armspid = {
		acceleration = 0.18,
		brakerate = 0.564,
		buildcostenergy = 3170,
		buildcostmetal = 166,
		buildpic = "ARMSPID.DDS",
		buildtime = 5090,
		canmove = true,
		category = "ALL TANK MOBILE WEAPON NOTSUB NOTSHIP NOTAIR NOTHOVER SURFACE",
		collisionvolumeoffsets = "0 0 0",
		collisionvolumescales = "28 15 28",
		collisionvolumetype = "box",
		corpse = "DEAD",
		description = "All-Terrain EMP Spider",
		energymake = 0.7,
		energyuse = 0.7,
		explodeas = "BIG_UNITEX",
		footprintx = 2,
		footprintz = 2,
		idleautoheal = 5,
		idletime = 600,
		maxdamage = 825,
		maxvelocity = 2.65,
		maxwaterdepth = 16,
		movementclass = "TKBOT2",
		mygravity = 10000,
		name = "Spider",
		nochasecategory = "ALL",
		objectname = "ARMSPID",
		seismicsignature = 0,
		selfdestructas = "BIG_UNIT",
		sightdistance = 550,
		stealth = true,
		turninplaceanglelimit = 140,
		turninplacespeedlimit = 1.749,
		turnrate = 1122,
		customparams = {},
		featuredefs = {
			dead = {
				blocking = false,
				category = "corpses",
				collisionvolumeoffsets = "0.0926513671875 -4.24316406278e-06 -0.909057617188",
				collisionvolumescales = "31.362487793 12.4340515137 31.2150268555",
				collisionvolumetype = "Box",
				damage = 450,
				description = "Spider Wreckage",
				energy = 0,
				featuredead = "HEAP",
				featurereclamate = "SMUDGE01",
				footprintx = 2,
				footprintz = 2,
				height = 40,
				hitdensity = 100,
				metal = 108,
				object = "ARMSPID_DEAD",
				reclaimable = true,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
			heap = {
				blocking = false,
				category = "heaps",
				damage = 225,
				description = "Spider Heap",
				energy = 0,
				featurereclamate = "SMUDGE01",
				footprintx = 2,
				footprintz = 2,
				height = 4,
				hitdensity = 100,
				metal = 43,
				object = "2X2A",
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
				[1] = "spider2",
			},
			select = {
				[1] = "spider",
			},
		},
		weapondefs = {
			spider = {
				areaofeffect = 8,
				beamtime = 0.1,
				corethickness = 0.2,
				craterboost = 0,
				cratermult = 0,
				duration = 0.01,
				explosiongenerator = "custom:EMPFLASH20",
				impactonly = 1,
				impulseboost = 0,
				impulsefactor = 0,
				laserflaresize = 6,
				name = "Paralyzer",
				noselfdamage = true,
				paralyzer = true,
				paralyzetime = 9,
				range = 220,
				reloadtime = 1.75,
				rgbcolor = "1 1 0",
				soundstart = "hackshot",
				soundtrigger = true,
				targetmoveerror = 0.3,
				thickness = 1,
				turret = true,
				weapontype = "BeamLaser",
				weaponvelocity = 800,
				damage = {
					default = 1750,
				},
			},
		},
		weapons = {
			[1] = {
				def = "SPIDER",
				onlytargetcategory = "SURFACE",
			},
		},
	},
}
