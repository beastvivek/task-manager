function test_sort_tags() {
	test_heading "sort_tags"
	local test_description="Should return sorted tags"
	local expected="cricket,football"
	local tags="football,cricket"
	local actual=$( sort_tags ${tags})
	assert_expectation "${expected}" "${actual}" "${test_description}"
}
