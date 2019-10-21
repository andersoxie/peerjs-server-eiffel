note
	description: "Summary description for {CONNECTED_CLIENTS}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CONNECTED_CLIENTS[G]


create
	make_with_capacity

feature -- Initialization

	make_with_capacity (a_capacity: INTEGER)
			-- Initialize with capacity of `a_capacity'.
		require
			valid_capacity: a_capacity > 0
		do
			create storage.make
			capacity := a_capacity
		ensure
			capacity_set: capacity = a_capacity
			empty: is_empty
		end

feature -- Element change

	put_client (a_element: separate G )
			-- Store element.
		require
			not_full: not is_full
		do
			storage.extend (a_element)
		ensure
			count_incremented: count = old count + 1
			not_empty: not is_empty
		end

	remove_client (a_element: separate G )
			-- Consume an element.
		require
			not_empty: not is_empty
		do
			storage.start
			-- TEMP to get it to compile
			--storage.search (a_element)
			storage.remove
		ensure
			count_decremented: count = old count - 1
			not_full: not is_full
		end


		start -- temproary to understand SCOOP and if I need it.
		do

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

	storage: LINKED_LIST [separate G]
			-- Implementation.

invariant
	capacity_positive: capacity > 0
	correct_count: storage.count <= capacity

end
