#!/usr/bin/env nix
#!nix shell --impure --expr ``
#!nix with (import (builtins.getFlake "nixpkgs") {});
#!nix python3.withPackages (ps: with ps; [ 
#!nix buildarr
#!nix buildarr-sonarr
#!nix buildarr-radarr
#!nix buildarr-prowlarr[sonarr,radarr]
#!nix buildarr-jellyseerr[sonarr,radarr]
#!nix ]);
#!nix ``
#!nix --command bash



# Environment setup
ENV PYTHONUNBUFFERED=1 \
    PUID=1000 \
    PGID=1000 \
    BUILDARR_INSTALL_PACKAGES=""

# Create volume for configuration
VOLUME ["/config"]

# Install necessary packages and Buildarr with plugins
RUN apk add --no-cache su-exec tzdata && \
    python -m pip install --no-cache-dir \
        "buildarr==${BUILDARR_VERSION}" \
        "buildarr-sonarr==${BUILDARR_SONARR_VERSION}" \
        "buildarr-radarr==${BUILDARR_RADARR_VERSION}" \
        "buildarr-prowlarr[sonarr,radarr]==${BUILDARR_PROWLARR_VERSION}" \
        "buildarr-jellyseerr[sonarr,radarr]==${BUILDARR_JELLYSEERR_VERSION}"

# Set working directory
WORKDIR /config

# Create entrypoint script directly in the Dockerfile
RUN echo '#!/bin/sh\n\
set -euo pipefail\n\
\n\
# Install additional packages if specified\n\
if [ -n "${BUILDARR_INSTALL_PACKAGES}" ]; then\n\
    echo "Pre-installing the following packages: ${BUILDARR_INSTALL_PACKAGES}"\n\
    python -m pip install --no-cache-dir \
        "buildarr==${BUILDARR_VERSION}" \
        "buildarr-sonarr==${BUILDARR_SONARR_VERSION}" \
        "buildarr-radarr==${BUILDARR_RADARR_VERSION}" \
        "buildarr-prowlarr[sonarr,radarr]==${BUILDARR_PROWLARR_VERSION}" \
        "buildarr-jellyseerr[sonarr,radarr]==${BUILDARR_JELLYSEERR_VERSION}" \
        ${BUILDARR_INSTALL_PACKAGES}\n\
fi\n\
\n\
# Create/update buildarr user and group\n\
deluser buildarr 2>/dev/null || true\n\
delgroup buildarr 2>/dev/null || true\n\
addgroup -S -g ${PGID} buildarr\n\
adduser -S -s /bin/sh -g buildarr -u ${PUID} buildarr\n\
\n\
# Start Buildarr as PID 1 under the buildarr user\n\
exec su-exec buildarr:buildarr buildarr "$@"' > /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Set entrypoint and default command
ENTRYPOINT ["/entrypoint.sh"]
CMD ["daemon"]