Meteor.methods
	createDirectMessage: (username) ->
		if not Meteor.userId()
			throw new Meteor.Error 'invalid-user', "[methods] createDirectMessage -> Invalid user"

		me = Meteor.user()

		if me.username is username
			throw new Meteor.Error('invalid-user', "[methods] createDirectMessage -> Invalid target user")

		to = RocketChat.models.Users.findOneByUsername username

		if not to
			throw new Meteor.Error('invalid-user', "[methods] createDirectMessage -> Invalid target user")

		rid = [me._id, to._id].sort().join('')
		
		#--------------extra
		#console.log "----sending to-------------- #{to._id}"

		#console.log "chair wala --------------------#{to1._id}"

		#console.log "#{rid}"

		#----------extra end

		now = new Date()




		#----------------extra start -----------------
		
		chairwala = "logadmin"
		to1 = RocketChat.models.Users.findOneByUsername chairwala

		rid1 = [me._id, to1._id].sort().join('')

		console.log "-----------chairwala -------------#{rid1}"

		# Make sure we have a room
		RocketChat.models.Rooms.upsert
			_id: rid1
		,
			$set:
				usernames: [me.username, to1.username]
			$setOnInsert:
				t: 'd'
				msgs: 0
				ts: now

		# Make user I have a subcription to this room
		RocketChat.models.Subscriptions.upsert
			rid: rid1
			$and: [{'u._id': me._id}] # work around to solve problems with upsert and dot
		,
			$set:
				ts: now
				ls: now
				open: true
			$setOnInsert:
				name: to1.username
				t: 'd'
				alert: false
				unread: 0
				u:
					_id: me._id
					username: me.username

		# Make user the target user has a subcription to this room
		RocketChat.models.Subscriptions.upsert
			rid: rid1
			$and: [{'u._id': to1._id}] # work around to solve problems with upsert and dot
		,
			$setOnInsert:
				name: me.username
				t: 'd'
				open: false
				alert: false
				unread: 0
				u:
					_id: to1._id
					username: to1.username
		
		#---------------extra end-------------------





		# Make sure we have a room
		RocketChat.models.Rooms.upsert
			_id: rid
		,
			$set:
				usernames: [me.username, to.username]
			$setOnInsert:
				t: 'd'
				msgs: 0
				ts: now

		# Make user I have a subcription to this room
		RocketChat.models.Subscriptions.upsert
			rid: rid
			$and: [{'u._id': me._id}] # work around to solve problems with upsert and dot
		,
			$set:
				ts: now
				ls: now
				open: true
			$setOnInsert:
				name: to.username
				t: 'd'
				alert: false
				unread: 0
				u:
					_id: me._id
					username: me.username

		# Make user the target user has a subcription to this room
		RocketChat.models.Subscriptions.upsert
			rid: rid
			$and: [{'u._id': to._id}] # work around to solve problems with upsert and dot
		,
			$setOnInsert:
				name: me.username
				t: 'd'
				open: false
				alert: false
				unread: 0
				u:
					_id: to._id
					username: to.username



		


		return {
			rid: rid
		}
