# syntax=docker/dockerfile:1

FROM centos:7
RUN yum -y group install "Development Tools" "Scientific Support"
RUN yum -y install python-devel wget vim zlib-devel gzip f2py python-yaml

WORKDIR /eft2obs

COPY env.sh .

COPY setup/setup_lhapdf.sh setup/setup_lhapdf.sh
SHELL ["/bin/bash", "-c"]
RUN ./setup/setup_lhapdf.sh

COPY setup/setup_mg5.sh setup/setup_mg5.sh
COPY setup/*.patch setup/
COPY setup/WeightCorrector.h setup/
SHELL ["/bin/bash", "-c"]
RUN ./setup/setup_mg5.sh

COPY setup/setup_rivet.sh setup/setup_rivet.sh
SHELL ["/bin/bash", "-c"]
RUN ./setup/setup_rivet.sh

COPY RivetPlugins RivetPlugins
COPY setup/setup_rivet_plugins.sh setup/setup_rivet_plugins.sh
SHELL ["/bin/bash", "-c"]
RUN ./setup/setup_rivet_plugins.sh

COPY setup/setup_model.sh setup/setup_model.sh
SHELL ["/bin/bash", "-c"]
RUN ./setup/setup_model.sh SMEFTsim_A_U35_alphaScheme_UFO_v2_1 SMEFTsim_MFV_MwScheme_UFO SMEFTsim_MFV_alphaScheme_UFO SMEFTsim_U35_MwScheme_UFO SMEFTsim_U35_alphaScheme_UFO SMEFTsim_general_MwScheme_UFO SMEFTsim_general_alphaScheme_UFO SMEFTsim_topU3l_MwScheme_UFO SMEFTsim_topU3l_alphaScheme_UFO SMEFTsim_top_MwScheme_UFO SMEFTsim_top_alphaScheme_UFO SMEFTatNLO 

COPY . .

CMD ["bash"]
