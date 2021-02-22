#!/usr/bin/env python3

class Config:
    """
    Class for providing Concourse configuration

    Attributes:
        __config  (dict)  Concourse resource configuration
    """

    def __init__(self, config):
        """
        Constructor for Config instance

        Parameters:
            config  (dict)  Concourse configuration as JSON
        """
        self.__config = config


    def get(self, key, source=None):
        """
        Method to retrieve Concourse configuration

        Parameters:
            key     (string)  Key to use to find configuration
            source  (string)  Key for subdict for finding configuration
        """
        if source is not None:
            subconfig = self.__config.get(source)
            if subconfig is not None:
                value = subconfig.get(key)
            else:
                value = None
        else:
            value = self.__config.get(key)

        return value


    def get_config(self):
        return self.__config


    def is_valid_source_config(self):
        for config_item in ["server_url", "access_token", "project", "repository", "server_type"]:
            if config_item not in self.__config["source"]:
                return False
        return True


    def is_valid_get_config(self):
        return True


    def is_valid_put_config(self):
        for config_item in ["path", "state"]:
            if config_item not in self.__config["params"]:
                return False
        return True