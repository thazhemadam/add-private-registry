import Base64
import Pkg
import TOML

include(joinpath(@__DIR__, "check_pkg_server.jl"))

function get_juliahub_token_toml()
    juliahub_token_encoded = ENV["JULIAHUB_TOKEN_ENCODED"] |> strip |> String
    @info "Is the encoded token being picked up properly?" juliahub_token_encoded # never do this! I'm only doing this to test things with a dummy value. But never expose secrets!
    juliahub_token_toml = String(Base64.base64decode(juliahub_token_encoded))
    @info "Is the encoded token being decoded properly?" juliahub_token_toml  # never do this! I'm only doing this to test things with a dummy value. But never expose secrets!
    return juliahub_token_toml
end

function check_auth_toml_file(token_file)
    # Sanity check to make sure that the `auth.toml` file is valid TOML
    d = TOML.parsefile(token_file)
    if !(d isa AbstractDict)
        msg = "The TOML file did not parse into a dictionary"
        @error msg typeof(d)
        throw(ErrorException(msg))
    end
    if isempty(d)
        msg = "The TOML file is empty"
        throw(ErrorException(msg))
    end
    return nothing
end

function main_create_auth_toml()
    @info "Running on Julia $(VERSION)..."
    juliahub_token_toml = get_juliahub_token_toml()
    @info "Is the token getting parsed properly?" juliahub_token_toml !== ""
    pkg_server = Pkg.pkg_server()
    server_dir = Pkg.PlatformEngines.get_server_dir("$(pkg_server)/", pkg_server)
    token_file = joinpath(server_dir, "auth.toml")
    @info "Token file: $(token_file)"
    @info "Does the token file already exist?" isfile(token_file)
    mkpath(dirname(token_file))
    open(token_file, "w") do io
        println(io, juliahub_token_toml)
        println(io)
    end
    @info "Does the token file already exist?" isfile(token_file)
    @info isfile(token_file)
    check_auth_toml_file(token_file)
    return nothing
end

main_create_auth_toml()
