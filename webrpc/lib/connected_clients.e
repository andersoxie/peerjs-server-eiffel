note
	description: "Summary description for {CONNECTED_CLIENTS}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CONNECTED_CLIENTS


create
	make_with_capacity

feature -- Initialization

	make_with_capacity (a_capacity: INTEGER)
			-- Initialize with capacity of `a_capacity'.
		require
			valid_capacity: a_capacity > 0
		do
			create storage.make
			storage.compare_objects
			capacity := a_capacity
		ensure
			capacity_set: capacity = a_capacity
			empty: is_empty
		end

feature -- Element change

	put_client (id, token: separate STRING )
			-- Store element.
		require
			not_full: not is_full
		do
			storage.extend ( create {CLIENT}.make (create {STRING}.make_from_separate (id), create {STRING}.make_from_separate (token)))
		ensure
			count_incremented: count = old count + 1
			not_empty: not is_empty
		end

	remove (client: separate STRING )
			-- Consume an element.
		require
			not_empty: not is_empty
		do
			storage.start
			storage.search (create {CLIENT}.make (create {STRING}.make_from_separate (client),""))
			if not storage.exhausted then
				storage.remove
			end
		ensure
			count_decremented: count = old count - 1
			not_full: not is_full
		end

		send_command_to_client(client_destination, json_string: separate STRING)
		do
			storage.start
			storage.search (create {CLIENT}.make (create {STRING}.make_from_separate (client_destination),""))
			if not storage.exhausted then
				storage.item.add_message( create {STRING}.make_from_separate (json_string))
			end
			-- ensure that it is added and that the size is +1 and added at the end.
		end

		get_command_to_client(client : separate STRING ) : separate STRING
		do
			Result := ""
			storage.start
			storage.search (create {CLIENT}.make (create {STRING}.make_from_separate (client),""))
			if not storage.exhausted then
				Result := storage.item.get_message.out
			end
		end

feature -- Status report

	is_full: BOOLEAN
			-- Is buffer full?
		do
			Result := (storage.count = capacity)
		ensure
			correct_result: Result = (storage.count = capacity)
		end

	is_empty: BOOLEAN
			-- Is buffer empty?
		do
			Result := storage.count = 0
		ensure
			correct_result: Result = (storage.count = 0)
		end

feature -- Measurement

	capacity: INTEGER
		-- Maximum number of elements.

	count: INTEGER
			-- The number of elements.
		do
			Result := storage.count
		ensure
			correct_result: Result = storage.count
		end

feature {NONE}-- Implementation

	storage: LINKED_LIST [ CLIENT]
			-- Implementation.

invariant
	capacity_positive: capacity > 0
	correct_count: storage.count <= capacity

end
