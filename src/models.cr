require "json"

module RentcastProxy
  module Models
    struct Address
      include JSON::Serializable

      @[JSON::Field(key: "addressLine1")]
      property address_line1 : String?

      @[JSON::Field(key: "addressLine2")]
      property address_line2 : String?

      property city : String?
      property state : String?

      @[JSON::Field(key: "zipCode")]
      property zip_code : String?

      property county : String?
    end

    struct Owner
      include JSON::Serializable

      property names : Array(String)?
      property type : String?

      @[JSON::Field(key: "mailingAddress")]
      property mailing_address : Address?
    end

    struct Features
      include JSON::Serializable

      @[JSON::Field(key: "architectureType")]
      property architecture_type : String?

      @[JSON::Field(key: "coolingType")]
      property cooling_type : String?

      @[JSON::Field(key: "exteriorType")]
      property exterior_type : String?

      property fireplace : Bool?

      @[JSON::Field(key: "garageSpaces")]
      property garage_spaces : Int32?

      @[JSON::Field(key: "heatingType")]
      property heating_type : String?

      property pool : Bool?

      @[JSON::Field(key: "roofType")]
      property roof_type : String?
    end

    struct TaxAssessment
      include JSON::Serializable

      property year : Int32?
      property value : Int32?

      @[JSON::Field(key: "landValue")]
      property land_value : Int32?

      @[JSON::Field(key: "improvementValue")]
      property improvement_value : Int32?
    end

    struct PropertyTax
      include JSON::Serializable

      property year : Int32?
      property amount : Int32?
    end

    struct Property
      include JSON::Serializable

      property id : String

      @[JSON::Field(key: "formattedAddress")]
      property formatted_address : String?

      @[JSON::Field(key: "addressLine1")]
      property address_line1 : String?

      @[JSON::Field(key: "addressLine2")]
      property address_line2 : String?

      property city : String?
      property state : String?

      @[JSON::Field(key: "zipCode")]
      property zip_code : String?

      property county : String?
      property latitude : Float64?
      property longitude : Float64?

      @[JSON::Field(key: "propertyType")]
      property property_type : String?

      property bedrooms : Int32?
      property bathrooms : Float64?

      @[JSON::Field(key: "squareFootage")]
      property square_footage : Int32?

      @[JSON::Field(key: "lotSize")]
      property lot_size : Int32?

      @[JSON::Field(key: "yearBuilt")]
      property year_built : Int32?

      property features : Features?

      @[JSON::Field(key: "taxAssessments")]
      property tax_assessments : Hash(String, TaxAssessment)?

      @[JSON::Field(key: "propertyTaxes")]
      property property_taxes : Hash(String, PropertyTax)?

      @[JSON::Field(key: "lastSaleDate")]
      property last_sale_date : String?

      @[JSON::Field(key: "lastSalePrice")]
      property last_sale_price : Int32?

      property owner : Owner?
    end

    struct PropertyResponse
      include JSON::Serializable

      property properties : Array(Property)
      property count : Int32
      property total : Int32
    end

    struct RentEstimate
      include JSON::Serializable

      property rent : Int32?
      property confidence : String?

      @[JSON::Field(key: "rentRangeLow")]
      property rent_range_low : Int32?

      @[JSON::Field(key: "rentRangeHigh")]
      property rent_range_high : Int32?
    end

    struct ValueEstimate
      include JSON::Serializable

      property value : Int32?
      property confidence : String?

      @[JSON::Field(key: "valueRangeLow")]
      property value_range_low : Int32?

      @[JSON::Field(key: "valueRangeHigh")]
      property value_range_high : Int32?
    end

    struct ErrorResponse
      include JSON::Serializable

      property error : String
      property message : String?
    end
  end
end
