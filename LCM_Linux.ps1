# An example Configuration for Linux

Configuration LinuxConfig {

    Import-DscResource -Module nx

    Node "linux01.lab.local" {

        nxFile ExampleFile {
            DestinationPath = "/tmp/example.txt"
            Contents = "hello world `n"
            Ensure = "Present"
            Type = "File"
        }
    }
}

LinuxConfig -OutputPath C:\dsc