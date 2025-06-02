require "./spec_helper"

describe "RentcastProxy Integration" do
  describe "Models" do
    it "deserializes property correctly" do
      json_data = File.read("spec/fixtures/single_property_response.json")
      property = RentcastProxy::Models::Property.from_json(json_data)

      property.id.should eq("12345")
      property.formatted_address.should eq("123 Main St, Austin, TX 78701")
      property.bedrooms.should eq(3)
      property.bathrooms.should eq(2.0)
    end

    it "deserializes properties collection correctly" do
      json_data = File.read("spec/fixtures/properties_response.json")
      response = RentcastProxy::Models::PropertyResponse.from_json(json_data)

      response.properties.size.should eq(2)
      response.count.should eq(2)
      response.total.should eq(156)
    end

    it "deserializes rent estimate correctly" do
      json_data = File.read("spec/fixtures/rent_estimate_response.json")
      estimate = RentcastProxy::Models::RentEstimate.from_json(json_data)

      estimate.rent.should eq(2450)
      estimate.confidence.should eq("High")
    end

    it "deserializes value estimate correctly" do
      json_data = File.read("spec/fixtures/value_estimate_response.json")
      estimate = RentcastProxy::Models::ValueEstimate.from_json(json_data)

      estimate.value.should eq(485000)
      estimate.confidence.should eq("Medium")
    end

    it "deserializes error response correctly" do
      json_data = File.read("spec/fixtures/error_response.json")
      error = RentcastProxy::Models::ErrorResponse.from_json(json_data)

      error.error.should eq("Not Found")
      error.message.should eq("Property not found with the specified ID")
    end
  end

  describe "Database" do
    it "initializes successfully" do
      RentcastProxy::Database.initialize_db
      File.exists?("cache.db").should be_true
    end
  end

  describe "CacheManager" do
    it "has proper default TTL" do
      RentcastProxy::CacheManager::DEFAULT_TTL_SECONDS.should eq(604800)
    end
  end
end
