Template.privateGroupsFlex.helpers
	tRoomMembers: ->
		return t('Members')

	selectedUsers: ->
		return Template.instance().selectedUsers.get()

	name: ->
		return Template.instance().selectedUserNames[this.valueOf()]

	groupName: ->
		return Template.instance().groupName.get()

	error: ->
		return Template.instance().error.get()

	autocompleteSettings: ->
		return {
			limit: 10
			# inputDelay: 300
			rules: [
				{
					# @TODO maybe change this 'collection' and/or template
					collection: 'UserAndRoom'
					subscription: 'userAutocomplete'
					field: 'username'
					template: Template.userSearch
					noMatchTemplate: Template.userSearchEmpty
					matchAll: true
					filter:
						exceptions: [Meteor.user().username].concat(Template.instance().selectedUsers.get())
					selector: (match) ->
						return { username: match }
					sort: 'username'
				}
			]
		}

	x: ->
		return Template.instance().x.get()
	debug11: ->
    	return Template.instance().x.get()

    isOkay: ->
    	return Template.instance().x.get() is true

    prin: ->
    	return Template.instance().prin.get()

    setter: ->
    	return Template.instance.x.set true


Template.privateGroupsFlex.events
	'autocompleteselect #pvt-group-members': (event, instance, doc) ->
		
		instance.selectedUsers.set instance.selectedUsers.get().concat doc.username

		instance.selectedUserNames[doc.username] = doc.name

		instance.prin.set doc.username

		event.currentTarget.value = ''
		event.currentTarget.focus()

		#extra
		instance.x.set false

			

	'click .remove-room-member': (e, instance) ->
		self = @
		users = Template.instance().selectedUsers.get()
		users = _.reject Template.instance().selectedUsers.get(), (_id) ->
			return _id is self.valueOf()

		Template.instance().selectedUsers.set(users)

		$('#pvt-group-members').focus()

		#extra
		instance.x.set true

	'click .cancel-pvt-group': (e, instance) ->
		SideNav.closeFlex ->
			instance.clearForm()

	'click header': (e, instance) ->
		SideNav.closeFlex ->
			instance.clearForm()

	'mouseenter header': ->
		SideNav.overArrow()

	'mouseleave header': ->
		SideNav.leaveArrow()

	'keydown input[type="text"]': (e, instance) ->
		Template.instance().error.set([])

	'click .save-pvt-group': (e, instance) ->
		
		#extra start

		eb = 'chair'
		instance.selectedUsers.set instance.selectedUsers.get().concat eb

		instance.selectedUserNames[eb] = eb

		event.currentTarget.value = ''
		event.currentTarget.focus()

		eb = 'vchair'
		instance.selectedUsers.set instance.selectedUsers.get().concat eb

		instance.selectedUserNames[eb] = eb

		event.currentTarget.value = ''
		event.currentTarget.focus()


		#extra end


		err = SideNav.validate()
		name = instance.find('#pvt-group-name').value.toLowerCase().trim()
		instance.groupName.set name
		FlowRouter.go 'group', { name: name }
		instance.x.set true
		if not err
			Meteor.call 'createPrivateGroup', name, instance.selectedUsers.get(), (err, result) ->
				if err
					if err.error is 'name-invalid'
						instance.error.set({ invalid: true })
						return
					if err.error is 'duplicate-name'
						instance.error.set({ duplicate: true })
						return
					if err.error is 'archived-duplicate-name'
						instance.error.set({ archivedduplicate: true })
						return
					return toastr.error err.reason
				
				SideNav.closeFlex()
				instance.clearForm()
				FlowRouter.go 'group', { name: name }
		else
			Template.instance().error.set({fields: err})

Template.privateGroupsFlex.onCreated ->
	instance = this
	instance.selectedUsers = new ReactiveVar []
	instance.selectedUserNames = {}
	instance.error = new ReactiveVar []
	instance.groupName = new ReactiveVar ''
	instance.x = new ReactiveVar(true)
	instance.prin = new ReactiveVar ''
	instance.custommsg = new ReactiveVar 'Please check group in More Private Groups -> '

	instance.clearForm = ->
		instance.error.set([])
		instance.groupName.set('')
		instance.selectedUsers.set([])
		instance.find('#pvt-group-name').value = ''
		instance.find('#pvt-group-members').value = ''
		this.x.set true
		instance.prin.set('')
		instance.custommsg.set('Please check group in More Private Groups -> ')
