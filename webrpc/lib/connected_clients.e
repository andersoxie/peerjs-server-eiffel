note
	description: "Contains currently connected clients"
	purpose: "[
			To keep track of conencted clients
		]"
	design_history: "[

		]"

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

	put_client (a_id, a_token: separate STRING )
			-- Create and store a client
		require
			not_full: not is_full
		do
			storage.extend ( create {CLIENT}.make (create {STRING}.make_from_separate (a_id), create {STRING}.make_from_separate (a_token)))
		ensure
			count_incremented: count = old count + 1
			not_empty: not is_empty
		end

	remove (a_client_id: separate STRING )
			-- Remove an element.
		require
			not_empty: not is_empty
		do
			storage.start
			storage.search (create {CLIENT}.make (create {STRING}.make_from_separate (a_client_id),""))
			if not storage.exhausted then
				storage.remove
			end
		ensure
			count_decremented: count = old count - 1
			not_full: not is_full
		end

	post_command_to_client(a_client_destination, a_json_string: separate STRING)
			-- Puts the message in the clients "mailbox"
		do
			storage.start
			storage.search (create {CLIENT}.make (create {STRING}.make_from_separate (a_client_destination),""))
			if not storage.exhausted then
				storage.item.add_message( create {STRING}.make_from_separate (a_json_string)) -- Store it in the client since we do not have access to the clients socket in this SCOOP region
			end
			-- ensure that it is added and that the size is +1 and added at the end.
		end

	consume_client_command(a_client_id : separate STRING ) : separate STRING
			-- Returns an empty STRING if no message que is empty
		do
			Result := ""
			storage.start
			storage.search (create {CLIENT}.make (create {STRING}.make_from_separate (a_client_id),""))
			if not storage.exhausted then
				Result := storage.item.consume_message.out
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
