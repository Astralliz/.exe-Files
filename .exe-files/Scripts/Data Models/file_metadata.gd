class_name FileMetadata
extends Resource 

@export var filename: String = ""             # Name of files
@export var extension: String = ""            # File types
@export var size_mb: float = 0.0              # File sizes
@export var publisher: String = "unknown"     # Publisher / Author of Files
@export var source: String = "unknown"        # Source / Origin of files
@export var modified_hours_ago: int = 9999    # Modified Hours
@export var hidden: bool = false              # If files have the hidden property
@export var signature_valid: bool = true      # Malicious code patterns
@export var requires_admin: bool = false      # Requires admin permission
@export var claimed_type: String = ""         # Claimed file type by Filetizen
@export var risk_score: float = 0.0           # Final Threat Level Score
@export var issues: Array = []                # All contributing indicators
