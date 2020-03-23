require 'rails_helper'

describe 'API password change' do
  let!(:user) { create(:user, :with_password, new_password: '123456') }
  let!(:profile) { create(:profile, :contact, :admin, user: user) }
  let!(:device) { create(:device, profile: profile, reporter: nil) }
  let(:headers) { { 'access-token' => device.token } }

  describe 'POST /change' do
    let!(:endpoint) { '/api/web/password/change' }

    def post_params(params)
      post endpoint, headers: headers, params: params
    end

    specify 'success' do
      old_password = user.encrypted_password
      expect(user.pwd_correct?('123456')).to be_truthy
      post_params(password: '654321', password_confirmation: '654321', current_password: '123456')
      expect(response.status).to eq(200)
      puts json(response.body)
      expect(json(response.body, 'success')).to eq(true)
      expect(user.reload.encrypted_password).not_to eq(old_password)
      expect(user.reload.pwd_correct?('654321')).to be_truthy
    end

    context 'fail' do
      context 'blank' do
        let(:errors) do
          [
            "Password can't be blank",
            "Password confirmation can't be blank",
            "Current password can't be blank"
          ]
        end

        it 'password/current_password/confirmation' do
          post_params({})
          expect(json(response.body, 'success')).to eq(false)
          expect(json(response.body)['errors']).to match_array(errors)
        end
      end
      context 'current_password is not valid' do
        specify 'passsword not match' do
          post_params(
            current_pasword: 'INVALID',
            password: '654321',
            password_confirmation: '654321'
          )
          expect(json(response.body, 'success')).to eq(false)
          expect(json(response.body)['errors']).to match_array([
            "Current password can't be blank"
          ])
        end
      end

      context 'password_confirmation invalid' do
        specify 'repond with error' do
          post_params(
            current_password: '123456',
            password: '654321',
            password_confirmation: '654'
          )
          expect(json(response.body, 'success')).to eq(false)
          expect(json(response.body)['errors']).to match_array([
            "Password confirmation is invalid"
          ])
        end

      end
    end
  end

end
