import os

# Check if the script is running in a build environment
IS_BUILD_ENV = os.getenv('IS_BUILD_ENV') == '1'

if not IS_BUILD_ENV:
    import base64
    import binascii

    def add_base64_padding(base64_string):
        missing_padding = len(base64_string) % 4
        if missing_padding:
            base64_string += '=' * (4 - missing_padding)
        return base64_string

    encoded_key = os.getenv('PRIVATE_KEY_BASE64')
    if not encoded_key:
        raise ValueError("Environment variable 'PRIVATE_KEY_BASE64' is not set.")

    encoded_key = add_base64_padding(encoded_key)

    try:
        private_key = base64.b64decode(encoded_key)
    except binascii.Error as e:
        raise ValueError(f"Failed to decode Base64 string: {e}")

    private_key_1 = private_key.replace(b'\\n', b'\n')
else:
    print("Skipping private key decoding during build.")
    private_key_1 = b""
