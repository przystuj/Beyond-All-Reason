return {
	chickenr2 = {
		acceleration = 1.035,
		activatewhenbuilt = true,
		autoheal = 50,
		bmcode = "1",
		brakerate = 0.805,
		buildcostenergy = 15000,
		buildcostmetal = 250,
		builder = false,
		buildpic = "chickens/chickenr2.DDS",
		buildtime = 4500,
		canguard = true,
		canmove = true,
		canpatrol = true,
		canstop = "1",
		category = "BOT MOBILE WEAPON ALL NOTSUB NOTSHIP NOTAIR NOTHOVER SURFACE CHICKEN EMPABLE",
		collisionvolumeoffsets = "0 -2 0",
		collisionvolumescales = "25 31 44",
		collisionvolumetype = "box",
		defaultmissiontype = "Standby",
		explodeas = "flamebug_death",
		footprintx = 3,
		footprintz = 3,
		leavetracks = true,
		maneuverleashlength = "640",
		mass = 600,
		maxdamage = 4500,
		maxvelocity = 4.5,
		maxwaterdepth = 0,
		movementclass = "CHICKSMALL",
		noautofire = false,
		nochasecategory = "VTOL",
		objectname = "Chickens/chickenr2.s3o",
		script = "Chickens/chickenr2.cob",
		seismicsignature = 4,
		selfdestructas = "flamebug_death",
		side = "THUNDERBIRDS",
		sightdistance = 200,
		smoothanim = true,
		steeringmode = "2",
		tedclass = "BOT",
		trackoffset = 0,
		trackstrength = 3,
		trackstretch = 1,
		tracktype = "ChickenTrack",
		trackwidth = 35,
		turninplace = true,
		turninplaceanglelimit = 90,
		turnrate = 1840,
		unitname = "chickenr2",
		upright = false,
		workertime = 0,
		customparams = {
			maxrange = "200",
			subfolder = "other/chickens",
			model_author = "KDR_11k, Beherith",
			normalmaps = "yes",
			normaltex = "unittextures/chicken_s_normals.png",
			--treeshader = "no",
		},
		sfxtypes = {
			explosiongenerators = {
				[1] = "custom:blank",
				[2] = "custom:blood_spray",
				[3] = "custom:blood_explode",
				[4] = "custom:dirt",
			},
			pieceexplosiongenerators = {
				[1] = "blood_spray",
				[2] = "blood_spray",
				[3] = "blood_spray",
			},
		},
		weapondefs = {
			chaseweapon = {
				craterboost = 0,
				cratermult = 0,
				edgeeffectiveness = 0.3,
				explosiongenerator = "custom:chickenspike-large-sparks-burn",
				impulseboost = 0,
				impulsefactor = 0,
				interceptedbyshieldtype = 4,
				name = "Claws",
				noselfdamage = true,
				proximitypriority = -4,
				range = 200,
				reloadtime = 30,
				size = 0.001,
				targetborder = 1,
				tolerance = 5000,
				turret = "true",
				weapontype = "Cannon",
				weaponvelocity = 500,
				damage = {
					default = 0.001,
				},
			},
			flamer = {
				areaofeffect = 64,
				avoidfeature = 0,
				avoidfriendly = 0,
				burst = 12,
				burstrate = 0.03333,
				colormap = "1 0.95 0.82 0.03   0.7 0.4 0.25 0.027   0.44 0.25 0.15 0.024   0.033 0.018 0.011 0.02   0.0 0.0 0.0 0.01",
				craterboost = 0,
				cratermult = 0,
				edgeeffectiveness = 0.3,
				explosiongenerator = "custom:burnblack",
				firestarter = 100,
				flamegfxtime = 1,
				groundbounce = false,
				impulseboost = 0,
				impulsefactor = 0,
				intensity = 0.65,
				name = "PlasmaThrower",
				noselfdamage = true,
				proximitypriority = 4,
				range = 310,
				reloadtime = 0.7,
				sizegrowth = 0.7,
				soundstart = "Flamhvy1",
				soundtrigger = 0,
				sprayangle = 100,
				targetborder = 0.75,
				targetmoveerror = 0.001,
				tolerance = 2500,
				turret = true,
				weapontimer = 1,
				weapontype = "Flame",
				weaponvelocity = 265,
				customparams = {
					expl_light_color = "1 0.33 0.04",
					expl_light_life_mult = 1.1,
					expl_light_radius_mult = 1.15,
					light_color = "1 0.5 0.05",
				},
				damage = {
					default = 40,
				},
			},
		},
		weapons = {
			[1] = {
				badtargetcategory = "VTOL",
				def = "CHASEWEAPON",
				maindir = "0 0 1",
				onlytargetcategory = "NOTAIR",
			},
			[2] = {
				badtargetcategory = "VTOL",
				def = "FLAMER",
				maindir = "0 0 1",
				maxangledif = 270,
				onlytargetcategory = "NOTAIR",
			},
		},
	},
}
