class_name Uuid

static func v4() -> String:
	var crypto := Crypto.new()
	var b: PackedByteArray = crypto.generate_random_bytes(16) # 128 bits

	# Set version = 4 (0100xxxx)
	b[6] = (b[6] & 0x0F) | 0x40
	# Set variant = RFC 4122 (10xxxxxx)
	b[8] = (b[8] & 0x3F) | 0x80

	var hex := b.hex_encode()
	return "%s-%s-%s-%s-%s" % [
		hex.substr(0, 8),
		hex.substr(8, 4),
		hex.substr(12, 4),
		hex.substr(16, 4),
		hex.substr(20, 12),
	]