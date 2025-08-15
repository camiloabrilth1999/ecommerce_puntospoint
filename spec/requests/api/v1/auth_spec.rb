require 'rails_helper'

RSpec.describe "Api::V1::Auth", type: :request do
  let!(:administrator) { create(:administrator, email: 'test@example.com', password: 'password123', active: true) }

  describe "POST /api/v1/auth/login" do
    context "with valid credentials" do
      it "returns success with JWT token and administrator data" do
        post "/api/v1/auth/login", params: {
          administrator: {
            email: 'test@example.com',
            password: 'password123'
          }
        }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['success']).to be true
        expect(json_response['token']).to be_present
        expect(json_response['administrator']['id']).to eq(administrator.id)
        expect(json_response['administrator']['email']).to eq('test@example.com')
        expect(json_response['administrator']['name']).to eq(administrator.name)
        expect(json_response['administrator']['role']).to eq(administrator.role)
      end

      it "generates a valid JWT token" do
        post "/api/v1/auth/login", params: {
          administrator: {
            email: 'test@example.com',
            password: 'password123'
          }
        }

        json_response = JSON.parse(response.body)
        token = json_response['token']

        # Verify token can be decoded
        decoded_admin = JwtService.verify_token(token)
        expect(decoded_admin).to eq(administrator)
      end
    end

    context "with invalid email" do
      it "returns unauthorized" do
        post "/api/v1/auth/login", params: {
          administrator: {
            email: 'invalid@example.com',
            password: 'password123'
          }
        }

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)

        expect(json_response['success']).to be false
        expect(json_response['error']).to eq('Invalid credentials or inactive account')
        expect(json_response['token']).to be_nil
      end
    end

    context "with invalid password" do
      it "returns unauthorized" do
        post "/api/v1/auth/login", params: {
          administrator: {
            email: 'test@example.com',
            password: 'wrongpassword'
          }
        }

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)

        expect(json_response['success']).to be false
        expect(json_response['error']).to eq('Invalid credentials or inactive account')
      end
    end

    context "with inactive administrator" do
      it "returns unauthorized" do
        administrator.update!(active: false)

        post "/api/v1/auth/login", params: {
          administrator: {
            email: 'test@example.com',
            password: 'password123'
          }
        }

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)

        expect(json_response['success']).to be false
        expect(json_response['error']).to eq('Invalid credentials or inactive account')
      end
    end

    context "with missing parameters" do
      it "returns error for missing email" do
        post "/api/v1/auth/login", params: {
          administrator: {
            password: 'password123'
          }
        }

        expect(response).to have_http_status(:unauthorized)
      end

      it "returns error for missing password" do
        post "/api/v1/auth/login", params: {
          administrator: {
            email: 'test@example.com'
          }
        }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /api/v1/auth/logout" do
    it "returns success message" do
      administrator = create(:administrator, email: 'test@test.com', password: 'password123', role: 'admin')
      token = JwtService.generate_token(administrator)

      delete "/api/v1/auth/logout", headers: { 'Authorization' => "Bearer #{token}" }

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)

      expect(json_response['success']).to be true
      expect(json_response['message']).to eq('Logged out successfully')
    end
  end
end
