Meteor.methods
	createPrivateGroup: (name, members) ->
		if not Meteor.userId()
			throw new Meteor.Error 'invalid-user', "[methods] createPrivateGroup -> Invalid user"

		unless RocketChat.authz.hasPermission(Meteor.userId(), 'create-p')
			throw new Meteor.Error 'not-authorized', '[methods] createPrivateGroup -> Not authorized'

		try
			nameValidation = new RegExp '^' + RocketChat.settings.get('UTF8_Names_Validation') + '$'
		catch
			nameValidation = new RegExp '^[0-9a-zA-Z-_.]+$'

		if not nameValidation.test name
			throw new Meteor.Error 'name-invalid'

		now = new Date()

		me = Meteor.user()

		members.push me.username

		# name = s.slugify name

		# avoid duplicate names
		if RocketChat.models.Rooms.findOneByName name
			if RocketChat.models.Rooms.findOneByName(name).archived
				throw new Meteor.Error 'archived-duplicate-name'
			else
				throw new Meteor.Error 'duplicate-name'

		# create new room
		room = RocketChat.models.Rooms.createWithTypeNameUserAndUsernames 'p', name, me, members,
			ts: now


		#for key of room
   			#console.log key + " -> " + room[key]  if room.hasOwnProperty(key)


		# set creator as group moderator.  permission limited to group by scoping to rid
		RocketChat.authz.addUserRoles(Meteor.userId(), ['moderator','owner'], room._id)

		for username in members

			#console.log '----------chalega for ------------' + username
			member = RocketChat.models.Users.findOneByUsername(username, { fields: { username: 1 }})
			if not member?
				continue

			extra = {}

			if username is me.username
				extra.ls = now
			else
				extra.alert = true

			RocketChat.models.Subscriptions.createWithRoomAndUser room, member, extra


		#console.log '----------sab sahi hai------------'
		for username in members
			
			#extra start
			message =
  				_id: Random.id()
  				rid: room._id
  				msg: '@' + username
  				ts: new Date

  			options =
  				1: me.username

  			Meteor.call "sendMessage", message, options
  			#extra end
  			#console.log '----------gaya ------------ '+ username

		return {
			rid: room._id
		}
