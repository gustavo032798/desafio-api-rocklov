require_relative "routes/signup"
require_relative "libs/mongo"

describe "POST /signup" do
    context "cadastro com sucesso" do
        before(:all) do
            payload = { name: "Gustavo da Silva", email: "gustavo@hotmail.com", password: "12345" }
            MongoDB.new.remove_user(payload[:email])

            @result = SignUp.new.create(payload)
        end

        it "valida status code" do
            expect(@result.code).to eql 200
        end

        it "valida id do usuario" do
            expect(@result.parsed_response["_id"].length).to eql 24
        end        
    end

    context "usuario duplicado" do
        before(:all) do
            # dado que eu tenho um novo usuario
            payload = { name: "Gabriel Carranca", email: "gabriel@hotmail.com", password: "12345" }
            MongoDB.new.remove_user(payload[:email])

            # e o email do usuario ja foi cadastrado no sistema
            SignUp.new.create(payload)

            # quando faço uma requisição para a rota /signup
            @result = SignUp.new.create(payload)
        end

        it "valida status code 409" do
            # então deve retornar 409
            expect(@result.code).to eql 409
        end

        it "deve retornar: Email already exists :(" do
            expect(@result.parsed_response["error"]).to eql "Email already exists :("
        end        
    end

    examples = Helpers::get_fixture("signup")

    examples.each do |e|
        context "#{e[:title]}" do
            before(:all) do
                @result = SignUp.new.create(e[:payload])
            end 
    
            it "valida status code #{e[:code]}" do
                expect(@result.code).to eql e[:code]
            end
    
            it "retorna erro: #{e[:error]}" do
                expect(@result.parsed_response["error"]).to eql e[:error]
            end        
        end
    end    
end

# examples = [
#         {
#             title: "campo nome vazio",
#             payload: { name: "", email: "gustavo.carranca@hotmail.com", password: "12345" },
#             code: 412,
#             error: "required name"
#         },
#         {
#             title: "sem o campo nome",
#             payload: { email: "gustavo.carranca@hotmail.com", password: "12345" },
#             code: 412,
#             error: "required name"
#         },    
#         {
#             title: "campo email vazio",
#             payload: { name: "Gustavo da Silva", email: "", password: "12345" },
#             code: 412,
#             error: "required email"
#         },    
#         {
#             title: "sem o campo email",
#             payload: { name: "Gustavo da Silva", password: "12345" },
#             code: 412,
#             error: "required email"
#         },
#         {
#             title: "email invalido",
#             payload: { name: "Gustavo da Silva", email: "gustavo.carranca#hotmail.com", password: "12345" },
#             code: 412,
#             error: "wrong email"
#         },
#         {
#             title: "campo senha vazio",
#             payload: { name: "Gustavo da Silva", email: "gustavo.carranca@hotmail.com", password: "" },
#             code: 412,
#             error: "required password"
#         },
#         {
#             title: "sem o campo senha",
#             payload: { name: "Gustavo da Silva", email: "gustavo.carranca@hotmail.com" },
#             code: 412,
#             error: "required password"
#         },
#         {
#             title: "todos os campos vazios",
#             payload: { name: "", email: "", password: "" },
#             code: 412,
#             error: "required name"
#         },
#     ]

#     puts examples.to_json