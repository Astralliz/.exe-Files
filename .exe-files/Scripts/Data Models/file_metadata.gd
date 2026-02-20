class_name FileMetadata
extends Resource 

# Basic identity
@export var filename: String = ""
@export var extension: String = ""

# Core metadata
@export var size_mb: float = 0.0
@export var publisher: String = "unknown"
@export var source: String = "unknown"
@export var modified_hours_ago: int = 9999
@export var hidden: bool = false

# Security attributes
@export var signature_valid: bool = true
@export var requires_admin: bool = false
@export var is_compressed: bool = false   # NEW (for compressed_exec rule)
#@export var claimed_type: String = ""         # Claimed file type by Filetizen
# Post-inspection attributes
@export var risk_score: float = 0.0           # Final Threat Level Score
@export var issues: Array = []                # All contributing indicators
