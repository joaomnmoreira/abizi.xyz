=======
Windows
=======

Upgrade digital license (hardware) to product key (OEM)
=======================================================

    1. Download `Windows 10 ISO <https://www.microsoft.com/en-gb/software-download/windows10ISO>`__;
    2. Burn an ISO to an USB pen with `Rufus <https://rufus.ie/>`__, or `Windows Media Creation Tool <https://www.microsoft.com/en-gb/software-download/windows10>`__;
    3. Browse '/sources' folder in burned USB pen, and `add/change two files <https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-setup-edition-configuration-and-product-id-files--eicfg-and-pidtxt>`__:
        - EI.cfg

        .. code-block:: text
           :linenos:
           :emphasize-lines: 2,4
            
            [Channel]
            OEM
            [VL]
            0

        - PID.txt

        .. code-block:: text
           :linenos:
           :emphasize-lines: 2
        
            [PID]
            Value=XXXXX-XXXXX-XXXXX-XXXXX-XXXXX

