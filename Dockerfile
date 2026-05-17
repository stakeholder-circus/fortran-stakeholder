FROM gcc:15 AS build
WORKDIR /app
COPY app ./app
COPY tests ./tests
RUN mkdir -p build \
    && gfortran -std=f2018 -ffree-line-length-none -fall-intrinsics -Wall -Wextra -pedantic app/stakeholder.f90 -o build/stakeholder \
    && tests/test_cli.sh ./build/stakeholder

FROM gcc:15
WORKDIR /app
LABEL org.opencontainers.image.title="fortran-stakeholder"
LABEL org.opencontainers.image.description="Deterministic-first Fortran stakeholder CLI"
COPY --from=build /app/build/stakeholder /usr/local/bin/fortran-stakeholder
ENTRYPOINT ["/usr/local/bin/fortran-stakeholder"]
CMD ["--list-values"]
