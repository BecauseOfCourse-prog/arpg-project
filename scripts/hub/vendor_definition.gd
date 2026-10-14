extends Resource
class_name VendorDefinition

enum StockMode { FIXED_UNLIMITED, DAILY_LIMITED }

@export var vendor_name: String = "Vendor"
@export var stock_mode: StockMode = StockMode.FIXED_UNLIMITED
@export var offers: Array[VendorOffer] = []
