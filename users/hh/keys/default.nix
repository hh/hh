# SSH public keys for hh
{...}: let
  withAll = keys: keys // {all = builtins.attrValues keys;};
in
  withAll {
    # Primary ed25519 key
    nextral = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICwsHmQtv++obVtbu8Nc9COPOLEG5N12jYk75dTCaRsT hh@nextral.sharing.io";

    # M1 Mac
    m1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIItrB/8JpOZIyhp00TSKPxLOs3ZsqGBciIkCJi+SyjzJ hh@m1.medusa.local";

    # Legacy RSA keys (optional, for older systems)
    p70 = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDUhS7BghZwYoLKSsQx7HBxeV9JaA8jIA/kQCrKR58wWbFW7o2qHSC5lD9eJuDH439ifzsG05OxOgsm3Q+Jrb+VTOY1MdGAIW7SV2/xqDjLWmS259qH5kSYaP8TBq2EZZ9mFmIdZPDA7Q5ezjNcyH/LqW0FxU7XqIzFsrZlhDTZ57KZgivRZZsyauwOOP8+nXNj4YGSeQfzpiZXIaTZpSqWOrgud2kIehkeraJTlkXIbLge2zqM0dGLHVEyVW3W8qFPbmZBTdVhH2Tkgz9NNeukgXPzBdhSzSCdA/pLZ28MYUGScaDkc6BhpXHJzBo5zTpyhDyeHoHPUUYyTmFPUc2d hh@p70";
  }
